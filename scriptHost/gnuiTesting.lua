--- Require elements used
local GNUI = require "GNUI.main"
local Button = require "GNUI.element.button"

--- Create elements
local screen = GNUI.getScreenCanvas()
local button = Button.new(screen)

button:setDimensions(100,100,200,200)