local GNUI = require("libraries.gnui")
local screen = GNUI.getScreenCanvas()

local fake_screen = screen:newContainer()
fake_screen:setDimensions(0,0,64,64)

events.WORLD_RENDER:register(function ()
   local t = client:getSystemTime() / 1000
   fake_screen:setAnchor((math.sin(t) * 0.1 + 0.5),(math.cos(t) * 0.1 + 0.5))
end)

fake_screen:setCanCaptureCursor(false)

local container = fake_screen:newContainer()
container:setDimensions(16,16,64,64)