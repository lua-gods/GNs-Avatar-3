if not goofy then return end -- requires the goofy plugin

local GNUI = require("libraries.gnui")
local GNUIElements = require("libraries.gnui.modules.elements")
local screen = GNUI.getScreenCanvas()

local texture = textures["textures.icons"]
local sprite_idle = GNUI.newSprite():setTexture(texture):setUV(1,1,13,13)
local sprite_alert = GNUI.newSprite():setTexture(texture):setUV(15,1,27,13)


local button = GNUIElements.newSingleSpriteButton(sprite_alert)
:setAnchor(0,1)
:setPos(2,-23):setSize(8,8)
screen:addChild(button)


local hide = false
button.PRESSED:register(function ()
   hide = not hide
   goofy:setDisableGUIElement("CHAT",hide)
end)