local GNUI = require("GNUI.main")
-- GNUI Modules
local GNUIElements = require("GNUI.modules.elements")
local GNUIWindow = require("GNUI.modules.windows")
local GNUIThemes = require("GNUI.modules.themes")
-- Screen Stuffs
local screen = GNUI.getScreenCanvas()
local Statusbar = require("scriptHost.statusbar")
local icon = GNUI.newSprite():setTexture(textures["textures.icons"]):setUV(28,28,41,41)

local button = Statusbar.newButtonSprite(icon)

GNUIWindow.newWindow()