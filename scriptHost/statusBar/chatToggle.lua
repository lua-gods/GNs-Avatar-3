if not goofy then return end -- requires the goofy plugin

local GNUI = require("libraries.gnui")
local GNUIElements = require("libraries.gnui.modules.elements")
local screen = GNUI.getScreenCanvas()
local Statusbar = require("scriptHost.statusbar")

local texture = textures["textures.icons"]
local sprite_idle = GNUI.newSprite():setTexture(texture):setUV(1,1,13,13)
local sprite_alert = GNUI.newSprite():setTexture(texture):setUV(15,1,27,13)


local button = Statusbar.newButtonSprite(sprite_idle)
local hide = false
button.PRESSED:register(function ()
   hide = not hide
   goofy:setDisableGUIElement("CHAT",hide)
end)