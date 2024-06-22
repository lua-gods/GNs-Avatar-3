local GNUI = require("libraries.gnui")
local screen = GNUI.getScreenCanvas()

local fake_screen = screen:newContainer()
fake_screen:setAnchor(0.2,0.2)

events.WORLD_RENDER:register(function ()
   local t = client:getSystemTime() / 500
   fake_screen:setDimensions(0,0,(math.sin(t) * 0.5 + 0.6)*128,(math.cos(t) * 0.5 + 0.6)*128)
end)


local container = fake_screen:newContainer()
container
:setDimensions(5,5,-5,-5)
:setAnchor(0,0,1,1)