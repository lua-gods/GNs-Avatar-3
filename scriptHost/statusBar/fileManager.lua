local GNUI = require("GNUI.main")
local GNUIWindow = require("GNUI.modules.windows")
local screen = GNUI.getScreenCanvas()
local Statusbar = require("scriptHost.statusbar")

local texture = textures["textures.icons"]
local icon = GNUI.newSprite():setTexture(texture):setUV(42,0,55,13)
local button = Statusbar.newButtonSprite("File Explorer",icon)


button.PRESSED:register(function ()
  GNUIWindow.newFileDialog(screen)
end)
