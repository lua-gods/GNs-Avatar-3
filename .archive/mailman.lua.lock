local GNUI = require("lib.GNUI.main")
local Mailman = require("lib.mailman")
local EventLib = require("lib.eventLib")


local Pages = require"lib.pages"
local Button = require"lib.GNUI.element.button"
local TextField = require"lib.GNUI.element.textField"

local peer ---@type Mailman.Peer

local host = "dc912a38-2f0f-40f8-9d6d-57c400185362"
local target = "e4b91448-3b58-4c1f-8339-d40f75ecacc4"

local SENT = EventLib.newEvent()
local RECIVED = EventLib.newEvent()

events.ENTITY_INIT:register(function ()
	peer = Mailman.newPeer("a")
	
	if player:getUUID() == target then
		host,target = target,host
	end
	
	peer.SENT:register(function (data)SENT:invoke(data) end)
	peer.RECIVED:register(function (data)RECIVED:invoke(data) end)
end)


local container = GNUI.newBox():setDimensions(40,40,-40,-40):setAnchorMax()
   local messageBox = TextField.new(container,true):setAnchorMax():setDimensions(0,0,0,-30)
	local sendButton = Button.new(container):setAnchor(0,1,0.5,1):setDimensions(0,-20,0,0)
	sendButton:setText("Send")
	
	local isSending = false
	
	sendButton.PRESSED:register(function ()
		if not isSending then
			peer:send{target = target, content = {messageBox.textField}}
			sendButton:setText("Sending :snail:")
		end
	end)
	
	SENT:register(function (data)
		sendButton:setText("Sent!")
	end)
	
	RECIVED:register(function (data)
		messageBox:setTextField(data[1])
		sendButton:setText("Send")
		GNUI.playSound("minecraft:entity.item.pickup",1)
	end)


local page = Pages.newPage("mailman",{bgOpacity=0})
---@param screen GNUI.Box
page.INIT:register(function (screen)
	screen:addChild(container)
	
end)

page.EXIT:register(function (screen)
	screen:removeChild(container)
end)