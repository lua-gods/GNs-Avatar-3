---@diagnostic disable: assign-type-mismatch, missing-fields

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

local function realizeChangesOnIndex(index)
   if history[index] then
      ---@diagnostic disable-next-line: param-type-mismatch
         host:setChatMessage(index,toJson(history[index].post_json))
   end
end

local utils = require("libraries.rawjsonUtils")
local env = {math=math}

-- Anti spam
local last_message = ""
local spam_combo = 1

local message_filters = {
   -- Theme
   {
      ---@param message chatscript.post_data
      post = function (message)
         
         if message.translate == "chat.type.text" then
            local json = message.post_json
            json.extra[1].text = ""
            json.extra[3] = {text = " : ",color="gray"}
         end
      end,
   },
   -- Anti Spam
   {
      ---@param message chatscript.post_data
      post = function (message)
         if last_message == message.plain_text then
            spam_combo = spam_combo + 1
            if spam_combo == 2 then
               utils.insertPrefix(utils.getIndexComponent(history[2].post_json,1),{text = "(x"..spam_combo..") ",color="red"})
            else
               if history[2] then
                  local component = utils.getIndexComponent(history[2].post_json,1)
                  if component then
                     component.text = "(x"..spam_combo..") "
                  end
               end
            end
            realizeChangesOnIndex(2)
            return true
         else
            last_message = message.plain_text
            spam_combo = 1
         end
      end,
   },
   -- Copy Coordinates
   {
      ---@param message chatscript.post_data
      post = function (message)
         if message.translate == "chat.type.text" then
            ---@param component table
            utils.filterPattern(message.post_json,"[%d-.]+%s+[%d-.]+%s+[%d-.]+",function (component)
               local axis = 0
               local colors = {"red","green","blue"}
               utils.filterPattern(component,"[%d-.]+",function (sub_component)
                  axis = axis + 1
                  sub_component.color = colors[axis]
                  sub_component.clickEvent = {action = "copy_to_clipboard", value = component.text}
                  sub_component.hoverEvent = {action = "show_text", contents = {text="Copy Coordinates to Clipboard"}}
                  sub_component.antiTamper = true
               end)
            end)
         end
      end,
   },
   --Calculator
   {
      ---@param message chatscript.post_data
      post = function (message)
         if message.translate == "chat.type.text" then
            ---@param component table
            utils.filterPattern(message.post_json,"[%d+%-*/ ()]+",function (component)
               if #component.text > 1 then
                  local ok,result = pcall(load("return "..component.text,"meth","t",env))
                  if ok and (type(result) == "number" or not result) then
                     if result then
                        component.clickEvent = {action = "copy_to_clipboard", value = tostring(result)}
                        component.hoverEvent = {action = "show_text", contents = {text="it's "..result.." btw"}}
                     end
                  end
                  component.antiTamper = true
                  component.color = "gray"
               end
            end)
         end
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
            end)
         end
      end,
   },
   -- Copy numbers
   {
      ---@param message chatscript.post_data
      post = function (message)
         if message.translate == "chat.type.text" then
            ---@param component table
            utils.filterPattern(message.post_json,"[%d.-]+",function (component)
               component.clickEvent = {action = "copy_to_clipboard", value = component.text}
               component.hoverEvent = {action = "show_text", contents = {text="Copy Numbers to Clipboard"}}
            end)
         end
      end,
   },
}

local recived_messages = 0
events.CHAT_RECEIVE_MESSAGE:register(function (message, json)
   recived_messages = recived_messages + 1
   local parsed_json = parseJson(json)
   local predata = {
      plain_text = message,
      translate = parsed_json.translate,
      with = parsed_json.translate and parsed_json.with or parsed_json,
      pre_json = parsed_json}

   for i = 1, #message_filters, 1 do
      if message_filters[i].pre then
         message_filters[i].pre(predata)
      end
   end
   
   -- history
   table.insert(history,recived_messages,predata)
   if #history > 30 then
      for i = 30, #history, 1 do
         history[i] = nil
      end
   end
   return toJson(predata.pre_json)
end)


events.WORLD_RENDER:register(function ()
   local i = 1
   while recived_messages >= i do
      local post_msg_data = host:getChatMessage(i)
      if not post_msg_data then return end
      local json = parseJson(post_msg_data.json)
      local data = history[i]
      data.time = post_msg_data.addedTime
      data.post_json = json
      local delete = false
      for j = 1, #message_filters, 1 do
         if message_filters[j].post then
            delete = delete or message_filters[j].post(data)
         end
      end
      if delete then
         host:setChatMessage(i)
         table.remove(history,i)
         recived_messages = recived_messages - 1
      else
         host:setChatMessage(i,toJson(data.post_json))
         i = i + 1
      end
   end
   recived_messages = 0
end)

