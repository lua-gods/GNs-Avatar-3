if not goofy then return end -- requires the goofy plugin

local GNUI = require("libraries.gnui")
local GNUIElements = require("libraries.gnui.modules.elements")
local screen = GNUI.getScreenCanvas()

local button = GNUIElements.newButton("toggle_chat")
:setAnchor(0,1)
:setPos(2,-23):setSize(8,8)
screen:addChild(button)

local hide = false
button.PRESSED:register(function ()
   hide = not hide
   goofy:setDisableGUIElement("CHAT",hide)
end)