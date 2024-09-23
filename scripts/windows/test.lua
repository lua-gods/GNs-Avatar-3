
if not host:isHost() then return end
local GNUI = require"GNUI.main"
local panels = require"scriptHost.panels"
local icons = textures["textures.icons"]

local icon = GNUI.newNineslice(icons,9,0,15,9)

panels.newTab("Example",icon)
panels.newTab("Example",icon)
panels.newTab("Example",icon)
panels.newTab("Example",icon)