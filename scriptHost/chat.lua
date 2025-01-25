--[[______  __
	/ ____/ | / / By: GNamimates | https://gnon.top | Discord: @gn8.
 / / __/  |/ / An advanced chat script for Figura.
/ /_/ / /|  / comes with Anti spam, Theme, Coordinates detection, auto Solve equations in messages, clickable HTTP Links and copyable numbers
\____/_/ |_/ Source: https://github.com/lua-gods/GNs-Avatar-3/blob/main/scriptHost/chat.lua]]
---@diagnostic disable: assign-type-mismatch, missing-fields

-- BIG MASSIVE NOTE, THIS SHIT SUCKS

---@type chatscript.data[]
local history = {}


---@class chatscript.data : HostAPI.chatMessage
---@field json Minecraft.RawJSONText.Component|Minecraft.RawJSONText.Component[]

local function applyChangesToIndex(i)
	if history[i] then
		---@diagnostic disable-next-line: param-type-mismatch
			host:setChatMessage(i,toJson(history[i].json))
	end
end

local utils = require("lib.rawjsonUtils")
local env = {math=math,vectors = vectors,vec=vec}
for key, value in pairs(math) do -- inject math into global
	env[key] = value
end

local function proxify(tbl)
	for key, value in pairs(tbl) do
		if type(value) == "table" then
			tbl[key] = proxify(value)
		end
	end
	local output = setmetatable({}, {__index = tbl, __newindex = function ()end})
	return output
end

local proxyEnv = proxify(env)

local function clone(tbl)
	local output = {}
	for k,v in pairs(tbl) do
		output[k] = v
	end
	return output
end


local keywords = {
	["true "] = true,
	["false "] = true,
	["nil "] = true,
	[" and"] = true,
	[" or"] = true,
	["not"] = true,
	[" if"] = true,
	[" then"] = true,
	["elseif "] = true,
	["else "] = true,
	["while "] = true,
	["do "] = true,
	[" for "] = true,
	[" in "] = true,
	["function"] = true,
	["local "] = true,
	["return"] = true,
	["break "] = true,
	["continue"] = true,
	["end"] = true,
	["%="] = true,
	["%+"] = true,
	["%-"] = true,
	["%*"] = true,
	["/"] = true,
	["%%"] = true,
	["%^"] = true,
	["%.%."] = true,
	["<"] = true,
	[">"] = true,
	["<="] = true,
	[">="] = true,
	["=="] = true,
	["~="] = true,
}


local filters = {
-- Theme
	---@param message chatscript.data
	function (message,i)
		local json = message.json
		if json.extra[1].text == "<" then
			json.extra[1] = ""
			json.extra[3] = {text = " : ",color="gray"}
		end
	end,
	---@param message chatscript.data
	function (message)
		local matched = false
		---@param c table
		utils.filterPattern(message.json,"#%x%x%x%x%x%x",function (c)
			c.color = c.text
			c.clickEvent = {action = "copy_to_clipboard", value = c.text}
			c.hoverEvent = {action = "show_text", contents = {text="Copy to Clipboard"}}
			matched = true
			c.antiTamper = true
		end)
		if not matched then
			---@param c table
			utils.filterPattern(message.json,"#%x%x%x",function (c)
				local r,g,b = c.text:sub(2,2),c.text:sub(3,3),c.text:sub(4,4)
				c.color = "#"..r..r..g..g..b..b
				c.clickEvent = {action = "copy_to_clipboard", value = c.text}
				c.hoverEvent = {action = "show_text", contents = {text="Copy to Clipboard"}}
				c.antiTamper = true
			end)
		end
		--if message.translate == ""
	end,
--HTTP Links
	---@param message chatscript.data
	function (message)
		---@param c table
		utils.filterPattern(message.json,"https?://[%a%d;,/?:@&=+%%bruh%$-_.!~*'()#]+",function (c)
			c.color = "yellow"
			c.underlined = true
			c.clickEvent = {action = "open_url", value = c.text}
			c.hoverEvent = {action = "show_text", contents = {text=c.text}}
			c.text = "<link>"
			c.antiTamper = true
		end)
	end,
	--Codeblock Eval
	---@param message chatscript.data
	function (message)
		---@param c table
		utils.filterPattern(message.json,"`([^`]+)`",function (c)
			if #c.text > 1 then
				local snippet = c.text:sub(2,-2) ---@type string
				snippet = snippet:gsub("STACK","stack")
				local prefix = "local STACK = 0;"
				
				local strings = {}
				
				snippet = snippet.format(snippet:gsub("@"," "),table.unpack(strings))
				
				-- save all the strings
				while true do -- [[]]
					local a,b = (snippet.." "):find("%[%[(.*)%]%][^%]]")
					if b then 
						strings[#strings+1] = snippet:sub(a,b)
						snippet = snippet:sub(1,a-1) .. "@" .. snippet:sub(b+1,-1)
					else break end
				end
				
				for i = 1, 100, 1 do
					local q = ("="):rep(i)
					while true do -- [=[]=]
						local a,b = (snippet.." "):find("%["..q.."%[(.*)%]"..q.."%][^%]]")
						if b then 
							b = b - 1
							strings[#strings+1] = snippet:sub(a,b)
							snippet = snippet:sub(1,a-1) .. "@" .. snippet:sub(b+1,-1)
						else break end
					end
				end
				
				while true do -- ""
					local a,b = snippet:find("\"(.*)\"")
					if b then 
						strings[#strings+1] = snippet:sub(a,b)
						snippet = snippet:sub(1,a-1) .. "@" .. snippet:sub(b+1,-1)
					else break end
				end
				
				while true do -- ''
					local a,b = snippet:find("'(.*)'")
					if b then 
						strings[#strings+1] = snippet:sub(a,b)
						snippet = snippet:sub(1,a-1) .. "@" .. snippet:sub(b+1,-1)
					else break end
				end
				
				
				local patchedSNippet = snippet
				patchedSNippet = patchedSNippet:gsub("do[ ;-]"," do STACK = STACK + 1 if STACK > 100 then break end ")
				patchedSNippet = patchedSNippet:gsub("until[ ;-]"," until STACK = STACK + 1 if STACK > 100 then break end ")
				c.text = "`"..snippet.."`"
				snippet = patchedSNippet
				
				local g = 0
				utils.filterPattern(c,"@",function (v)
					g = g + 1
					v.text = strings[g]
					v.color = "#56c0f0"
					v.antiTamper = true
				end)
				
				for key, _ in pairs(keywords) do
					utils.filterPattern(c,key,function (v)
						v.color = "#f5555d"
						v.antiTamper = true
					end)
				end
				
				snippet = snippet.format(snippet:gsub("@","%%s"),table.unpack(strings))
				
				while true do -- patch functions
					local _,a = snippet:find("%a%([^)]*%)")
					if a then
						snippet = snippet:sub(1,a-1) .. "STACK = STACK + 1 if STACK > 100 then break end " .. snippet:sub(a+1,-1)
					else break end
				end
				--print(prefix .. "return" .. snippet)
				local tempEnv = setmetatable({}, {__index = env or proxyEnv})
				local ok,result = pcall(load(prefix .. "return " .. snippet,"math",tempEnv))
				if not ok then
					ok,result = pcall(load(prefix..snippet,"math",clone(env)))
				end
				if ok and result then
					c.color = "#ffffff"
					c.clickEvent = {action = "copy_to_clipboard", value = tostring(result)}
					c.hoverEvent = {action = "show_text", contents = {{text=result},{text="\n^ Click to Copy to Clipboard\n",color="gold"},{text=snippet,color="gray"}}}
				end
				
				c.antiTamper = true
			end
		end)
	end,
	function (message)
		---@param c Minecraft.RawJSONText.Component
		utils.filterPattern(message.json,"~~.+~~",function (c)
			c.color = c.color
			c.strikethrough = true
			c.text = c.text:sub(3,-3)
			c.antiTamper = true
		end)
	end,
	function (message)
		---@param c Minecraft.RawJSONText.Component
		utils.filterPattern(message.json,"*.+*",function (c)
			c.color = c.color
			c.italic = true
			c.text = c.text:sub(2,-2)
			c.antiTamper = true
		end)
	end,
	function (message)
		---@param c Minecraft.RawJSONText.Component
		utils.filterPattern(message.json,"__.+__",function (c)
			c.color = c.color
			c.underlined = true
			c.text = c.text:sub(3,-3)
			c.antiTamper = true
		end)
	end,
	function (message)
		---@param c Minecraft.RawJSONText.Component
		utils.filterPattern(message.json,"||.+||",function (c)
			local text = c.text
			c.color = "gray"
			c.text = ("|"):rep(client.getTextWidth(text)/2)
			c.hoverEvent = {
				action = "show_text",
				contents = {
					text = text:sub(3,-3),
					color = c.color
				}
			}
			c.antiTamper = true
		end)
	end,
	function (message)
		---@param c Minecraft.RawJSONText.Component
		utils.filterPattern(message.json,"__.+__",function (c)
			c.color = c.color
			c.underlined = true
			c.text = c.text:sub(3,-3)
			c.antiTamper = true
		end)
	end,
--Calculator
	---@param message chatscript.data
	function (message)
		---@param c table
		utils.filterPattern(message.json,"[%d+%-*^./ ()]+",function (c)
			if #c.text > 1 then
				local ok,result = pcall(load("return "..c.text))
				if ok and (type(result) == "number" or not result) then
					if result and tostring(result) ~= c.text then
						c.clickEvent = {action = "copy_to_clipboard", value = tostring(result)}
						c.hoverEvent = {action = "show_text", contents = {text="= "..result}}
					end
					c.antiTamper = true
				end
			end
		end)
	end,
}
--`for i = 1, 10, 1 do end; return 1+1`

--- flattens all nested components into one big array.
---@param input Minecraft.RawJSONText.Component|Minecraft.RawJSONText.Component[]
local function flattenJsonText(input)
	input = clone(input) ---@type Minecraft.RawJSONText.Component|Minecraft.RawJSONText.Component[]
	if input[1] then -- is an array
		for i = 1, #input, 1 do
			input[i] = flattenJsonText(input[i])
		end
	else -- is a component
		if input.extra then
			local extra ---@type Minecraft.RawJSONText.Component[]
			if input.extra[1] then -- is an array
				extra = input.extra
			else
				extra = {input.extra}
			end
			local output = {input}
			input.extra = nil
			for i = 1, #extra, 1 do
				local ec = extra[i]
				local ecFlat = clone(ec)
				for key, value in pairs(input) do
					ecFlat[key] = ec[key] or value
				end
				
				ecFlat = flattenJsonText(ecFlat) -- flattens nested extra tags
				
				-- merges the tables into one array
				if ecFlat[1] then -- is an array
					for j = 1, #ecFlat, 1 do
						output[#output+1] = ecFlat[j]
					end
				else output[#output+1] = ecFlat end
			end
			input = output
		end
	end
	return input
end


local recivedMsgs = 0
for i = 1, 100, 1 do
	if not host:getChatMessage(i) then break
	else
		recivedMsgs = i
	end
end

events.CHAT_RECEIVE_MESSAGE:register(function ()
	recivedMsgs = recivedMsgs + 1
end)



events.POST_WORLD_RENDER:register(function ()
	while 0 < recivedMsgs do
		local data = host:getChatMessage(recivedMsgs)
		if data then
			if data.json then data.json = parseJson(data.json)end
			---@cast data chatscript.data
			if data.message:sub(1,5) ~= "[lua]" then
				if data.json.extra or (data.json[1] and data.json[1].text) then
				if not (data.json.extra[1].hoverEvent and data.json.extra[1].hoverEvent.contents and (data.json.extra[1].hoverEvent.contents == "Processed" or data.json.extra[1].hoverEvent.contents.text == "Processed")) then
						for _, fun in pairs(filters) do fun(data) end
						
						table.insert(data.json.extra,1,{text="",hoverEvent = {action="show_text",contents = "Processed"}})
						host:setChatMessage(recivedMsgs,toJson(data.json))
					end
				end
			end
		end
		recivedMsgs = recivedMsgs - 1
	end
	recivedMsgs = 0
end)