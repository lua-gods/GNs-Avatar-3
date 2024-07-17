if not goofy then return end -- requires the goofy plugin

local GNUI = require("libraries.gnui")
local GNUIElements = require("libraries.gnui.modules.elements")
local screen = GNUI.getScreenCanvas()
local Statusbar = require("scriptHost.statusbar")

local texture = textures["textures.icons"]
local icon = GNUI.newSprite():setTexture(texture):setUV(1,1,13,13)


local button = Statusbar.newButtonSprite(icon)