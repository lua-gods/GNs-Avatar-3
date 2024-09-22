local GNUI = require"GNUI.main"
local Theme = require"GNUI.theme"
local Button = require"GNUI.element.button"
local eventLib = require"libraries.eventLib"
local screen = GNUI.getScreenCanvas()


local base = GNUI.newBox(screen)
:setDimensions(92,0,0,0)
:setAnchor(0.5,0,1,1)

local baseButton = Button.new(base)
baseButton:setSize(16,16)