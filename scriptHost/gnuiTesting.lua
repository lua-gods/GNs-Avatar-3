local GNUI = require"GNUI.main"
local Theme = require"GNUI.theme"

local Button = require"GNUI.element.button"
local Slider = require"GNUI.element.slider"
local TextField = require"GNUI.element.textField"

local screen = GNUI.getScreenCanvas()

Button.new(screen):setPos(10,10):setSize(100,20):setText("Test Button")
Slider.new(false,0,20,1,2,screen):setPos(10,40):setSize(100,20)
TextField.new(screen):setPos(10,70):setSize(100,20)