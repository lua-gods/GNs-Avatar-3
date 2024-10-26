local GNUI = require"GNUI.main"

local Button = require"GNUI.element.button"
local Slider = require"GNUI.element.slider"
local TextField = require"GNUI.element.textField"

local screen = GNUI.getScreenCanvas()

local btn = Button.new(screen)
:setPos(10,10)
:setSize(100,20)
:setText("Example Button")

btn.PRESSED:register(function () 
  print("ive been pressed!")
end)

Slider.new(false,0,20,1,2,screen)
:setPos(10,40)
:setSize(100,20)

TextField.new(screen)
:setPos(10,70)
:setSize(100,20)
.FIELD_CONFIRMED:register(function (text)
  print("You typed "..text)
end)
