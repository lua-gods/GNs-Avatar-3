local GNUI = require"GNUI.main"
local Theme = require"GNUI.theme"
local Button = require"GNUI.element.button"
local eventLib = require"libraries.eventLib"

local Box = require"GNUI.primitives.box"

local screen = GNUI.getScreenCanvas()
local box1 = GNUI.newBox(screen)
box1:setAnchor(0,0,1,1)

local baseButton = Button.new(box1)
baseButton:setSize(16,16)