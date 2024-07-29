if not goofy then return end -- requires the goofy plugin

local GNUI = require("libraries.GNUI.main")
local GNUIElements = require("libraries.GNUI.modules.elements")
local screen = GNUI.getScreenCanvas()
local Statusbar = require("scriptHost.statusbar")

local texture = textures["textures.icons"]
local sprite_idle = GNUI.newSprite():setTexture(texture):setUV(1,1,13,13)
local sprite_alert = GNUI.newSprite():setTexture(texture):setUV(15,1,27,13)


local button = Statusbar.newButtonSprite(sprite_idle)
local hide = false

events.CHAT_RECEIVE_MESSAGE:register(function ()
   if hide then
      button:setSprite(sprite_alert)
   end
end)

button.PRESSED:register(function ()
   button:setSprite(sprite_idle)
   hide = not hide
   goofy:setDisableGUIElement("CHAT",hide)
end)