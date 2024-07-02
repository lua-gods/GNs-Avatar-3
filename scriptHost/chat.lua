---@diagnostic disable: assign-type-mismatch, missing-fields

---@type chatscript.post_data[]
local msg_data = {}

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

local utils = require("libraries.rawjsonUtils")
local env = {math=math}

---@type table<integer,{post: fun(message: chatscript.post_data), pre: fun(message: chatscript.pre_data)}>
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
   --Calculator
   {
      ---@param message chatscript.post_data
      post = function (message)
         if message.translate == "chat.type.text" then
            ---@param component table
            utils.fragment(message.post_json,"%[[^]]+%]",function (component)
               local ok,result = pcall(load("return "..component.text:sub(2,-2),"meth","t",env))
               if ok and (type(result) == "number" or not result) then
                  if result then
                     component.text = component.text .. " = " .. result
                     component.clickEvent = {action = "copy_to_clipboard", value = tostring(result)}
                     component.hoverEvent = {action = "show_text", contents = {text=tostring(result)}}
                  end
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
            utils.fragment(message.post_json,"https?://[%a%d;,/?:@&=+%$-_.!~*'()#]+",function (component)
               component.color = "yellow"
               component.underlined = "true"
               component.clickEvent = {action = "open_url", value = component.text}
               component.hoverEvent = {action = "show_text", contents = {text="Open URL"}}
            end)
         end
      end,
   },
   -- Copy Coordinates
   {
      ---@param message chatscript.post_data
      post = function (message)
         if message.translate == "chat.type.text" then
            ---@param component table
            utils.fragment(message.post_json,"[%d-.]+%s+[%d-.]+%s+[%d-.]+",function (component)
               local axis = 0
               local colors = {"red","green","blue"}
               utils.fragment(component,"[%d-.]+",function (sub_component)
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
   -- Copy numbers
   {
      ---@param message chatscript.post_data
      post = function (message)
         if message.translate == "chat.type.text" then
            ---@param component table
            utils.fragment(message.post_json,"[%d.-]+",function (component)
               component.clickEvent = {action = "copy_to_clipboard", value = component.text}
               component.hoverEvent = {action = "show_text", contents = {text="Copy Numbers to Clipboard"}}
            end)
         end
      end,
   }
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
   msg_data[recived_messages] = predata
   return toJson(predata.pre_json)
end)


events.WORLD_RENDER:register(function ()
   for i = 1, recived_messages, 1 do
      local post_msg_data = host:getChatMessage(i)
      
      local json = parseJson(post_msg_data.json)
      local data = msg_data[i]
      data.time = post_msg_data.addedTime
      data.post_json = json
      for j = 1, #message_filters, 1 do
         if message_filters[j].post then
            message_filters[j].post(data)
         end
      end
      host:setChatMessage(i,toJson(data.post_json))
   end
   recived_messages = 0
   msg_data = {}
end)

