
if true then return end
local GNUI = require"lib.GNUI.main"
local panels = require"scriptHost.panels"
local icons = textures["textures.icons"]

local icon = GNUI.newNineslice(icons,9,0,15,9)

for i = 1, 10, 1 do
  panels.newTab("Example",icon)
end