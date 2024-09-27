--[[______  __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / An advanced chat script for Figura.
/ /_/ / /|  / comes with Anti spam, Theme, Coordinates detection, auto Solve equations in messages, clickable HTTP Links and copyable numbers
\____/_/ |_/ Source: https://github.com/lua-gods/GNs-Avatar-3/blob/main/scriptHost/chat.lua]]
---@diagnostic disable: assign-type-mismatch, missing-fields

-- BIG MASSIVE NOTE, THIS SHIT SUCKS

---@type chatscript.post_data[]
local history = {}

---@class chatscript.post_data
---@field pre_json table
---@field post_json table
---@field plain_text string
---@field translate string?
---@field time number
---@field with table

---@class chatscript.pre_data
---@field pre_json table
---@field plain_text string
---@field translate string?
---@field time number
---@field with table

local function applyChangesToIndex(i)
  if history[i] then
    ---@diagnostic disable-next-line: param-type-mismatch
      host:setChatMessage(i,toJson(history[i].post_json))
  end
end

local utils = require("libraries.rawjsonUtils")
local env = {math=math}

local message_filters = {
  -- Theme
  {
    ---@param message chatscript.post_data
    ---@param i integer
    post = function (message,i)
      if message.translate == "chat.type.text" then
        local json = message.post_json
        json.extra[1] = ""
        json.extra[3] = {text = " : ",color="gray"}
      end
    end,
  },
  {
    ---@param message chatscript.post_data
    post = function (message)
      if message.translate == "chat.type.text" then
        local matched = false
        ---@param component table
        utils.filterPattern(message.post_json,"#%x%x%x%x%x%x",function (component)
          component.color = component.text
          component.clickEvent = {action = "copy_to_clipboard", value = component.text}
          component.hoverEvent = {action = "show_text", contents = {text="Copy to Clipboard"}}
          matched = true
          component.antiTamper = true
        end)
        if not matched then
          ---@param component table
          utils.filterPattern(message.post_json,"#%x%x%x",function (component)
            local r,g,b = component.text:sub(2,2),component.text:sub(3,3),component.text:sub(4,4)
            component.color = "#"..r..r..g..g..b..b
            component.clickEvent = {action = "copy_to_clipboard", value = component.text}
            component.hoverEvent = {action = "show_text", contents = {text="Copy to Clipboard"}}
            component.antiTamper = true
          end)
        end
      end
      --if message.translate == ""
    end,
  },
  --HTTP Links
  {
    ---@param message chatscript.post_data
    post = function (message)
      if message.translate == "chat.type.text" then
        ---@param component table
        utils.filterPattern(message.post_json,"https?://[%a%d;,/?:@&=+%$-_.!~*'()#]+",function (component)
          component.color = "yellow"
          component.underlined = "true"
          component.clickEvent = {action = "open_url", value = component.text}
          component.hoverEvent = {action = "show_text", contents = {text="Open URL"}}
          component.antiTamper = true
        end)
      end
    end,
  },
  --Calculator
  {
    ---@param message chatscript.post_data
    post = function (message,i)
      if message.translate == "chat.type.text" then
        ---@param component table
        utils.filterPattern(message.post_json,"[%d+%-*^./ ()]+",function (component)
          if #component.text > 1 then
            local ok,result = pcall(load("return "..component.text,"meth",env))
            if ok and (type(result) == "number" or not result) then
              if result then
                component.clickEvent = {action = "copy_to_clipboard", value = tostring(result)}
                component.hoverEvent = {action = "show_text", contents = {text="it's "..result.." btw"}}
              end
            end
            component.antiTamper = true
          end
        end)
      end
    end,
  },
}

local function clone(tbl)
  local output = {}
  for k,v in pairs(tbl) do
    output[k] = v
  end
  return output
end

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

local recived_messages = 0
events.CHAT_RECEIVE_MESSAGE:register(function (message, json)
  recived_messages = recived_messages + 1
  local parsed_json = flattenJsonText(parseJson(json))
  local data = {
    plain_text = message,
    translate = parsed_json.translate,
    with = parsed_json.translate and parsed_json.with or parsed_json,
    pre_json = parsed_json}

  for i = 1, #message_filters, 1 do
    if message_filters[i].pre then
      message_filters[i].pre(data,i)
    end
  end
  table.insert(history,1,data)
  
  -- cap of history
  if #history > 30 then
    for i = 30, #history, 1 do
      history[i] = nil
    end
  end
  return toJson(data.pre_json)
end)


events.WORLD_RENDER:register(function ()
  local i = recived_messages
  while 0 < i do
    local data = history[i]
    if data.plain_text:sub(1,5) ~= "[lua]" then
      local post_msg_data = host:getChatMessage(i)
      --if not post_msg_data then return end
      data.time = post_msg_data.addedTime
      data.post_json = parseJson(post_msg_data.json)
      local delete = false
      for j = 1, #message_filters, 1 do
        if message_filters[j].post then
          delete = delete or message_filters[j].post(data,i)
        end
      end
      if delete then
        host:setChatMessage(i)
        table.remove(history,i)
      else
        host:setChatMessage(i,toJson(data.post_json))
      end
    end
    i = i -1
  end
  recived_messages = 0
end)