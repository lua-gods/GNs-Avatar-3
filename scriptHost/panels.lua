local GNUI = require"GNUI.main"
local Theme = require"GNUI.theme"
local Button = require"GNUI.element.button"
local eventLib = require"libraries.eventLib"
local screen = GNUI.getScreenCanvas()


local base = GNUI.newBox(screen)
:setDimensions(92,0,0,0)
:setAnchor(0.5,0,1,1)

local icons = textures["textures.icons"]

local baseButton = Button.new(base)
:setSize(15,15):setPos(0,-19)
:setAnchor(0,1,0,1)

--- Main Button Icon
local iconSize = 9/2
GNUI.newBox(baseButton)
:setNineslice(GNUI.newNineslice(icons,0,0,8,8))
:setAnchor(0.5,0.5)
:setDimensions(-iconSize,-iconSize,iconSize,iconSize)
:setBlockMouse(false)