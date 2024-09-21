local GNUI = require "GNUI.main"
local screen = GNUI.getScreenCanvas()

local box = GNUI.newBox(screen)
box:setTextBehavior("WRAP"):setTextAlign(0.5,0.5)
:setText("Lorem ipsum dolor sit amet consectetur, adipisicing elit. Culpa optio, aliquid non vero nemo laborum? Quaerat minima quisquam magnam ullam neque? Dolorum dolore ut earum cum animi nulla voluptate maxime?")
box:setTextEffect("OUTLINE")

events.WORLD_RENDER:register(function ()
  local t = client:getSystemTime()/500
  box:setDimensions(100,100,300+math.sin(t)*100,200)
end)