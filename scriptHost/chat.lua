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

---@type table<integer,{post: fun(message: chatscript.post_data), pre: fun(message: chatscript.pre_data)}>
local message_filters = {}
for key, path in pairs(listFiles("scriptHost.chatFilters")) do
   message_filters[#message_filters+1] = require(path)
end

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

