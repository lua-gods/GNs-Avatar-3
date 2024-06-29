
local recived_messages = 0
events.CHAT_RECEIVE_MESSAGE:register(function (message, json)
   recived_messages = recived_messages + 1
end)

--events.WORLD_RENDER:register(function ()
--   for i = 1, recived_messages, 1 do
--      host:setChatMessage(i, "Message " .. i)
--   end
--   recived_messages = 0
--end)