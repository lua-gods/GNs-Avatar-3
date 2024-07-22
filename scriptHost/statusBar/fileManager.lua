local GNUI = require("libraries.gnui")
local GNUIWindow = require("libraries.gnui.modules.windows")
local screen = GNUI.getScreenCanvas()
local Statusbar = require("scriptHost.statusbar")

local texture = textures["textures.icons"]
local icon = GNUI.newSprite():setTexture(texture):setUV(42,0,55,13)
local button = Statusbar.newButtonSprite(icon)


button.PRESSED:register(function ()
   GNUIWindow.newFileDialog(screen,"OPEN")
end)
