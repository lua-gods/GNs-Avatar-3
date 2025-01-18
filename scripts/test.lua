local Mailman = require("lib.mailman")

events.ENTITY_INIT:register(function ()
local peer = Mailman.newPeer("a")

if player:getUUID() == "dc912a38-2f0f-40f8-9d6d-57c400185362" then
	peer:send({
		target = "e4b91448-3b58-4c1f-8339-d40f75ecacc4",
		content = {"Hello World"}
	})
end

peer.RECIVED:register(function (data)
	print("RECIVED: ",toJson(data))
	end)
end)