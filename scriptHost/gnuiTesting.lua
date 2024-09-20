local GNUI = require "GNUI.main"
local screen = GNUI.getScreenCanvas()

local box = GNUI.newBox(screen)
local button = require"GNUI.element.button"

box:setDimensions(100,100,200,200)