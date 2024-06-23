local GNUI = require("libraries.gnui")
local gnui_extras = require("libraries.gnui_extras")
local screen = GNUI.getScreenCanvas()

--do
--   local fake_screen = GNUI.newContainer()
--   screen:addChild(fake_screen)
--   fake_screen:setAnchor(0.1,0.1) 
--   
--   events.WORLD_RENDER:register(function ()
--      local t = client:getSystemTime() / 500
--      fake_screen:setDimensions(0,0,(math.sin(t) * 0.5 + 1)*24,(math.cos(t) * 0.5 + 1)*24)
--   end)
--   
--   local container = GNUI.newContainer()
--   fake_screen:addChild(container)
--   container
--   :setDimensions(5,5,-5,-5)
--   :setAnchor(0,0,1,1)
--   :setCustomMinimumSize(16,16)
--   :setGrowDirection(-1,-1)
--end

local button = gnui_extras.newButton()

screen:addChild(button)
button:setPos(16,16):setSize(64,0)
button:setText("Hello World")
--events.WORLD_TICK:register(function ()
--   local t = client:getSystemTime() / 500
--   button:setPos(64,64):setSize((math.sin(t) * 0.5 + 0.6) * 64,1)
--end)

--local last = screen
--for i = 1, 7, 1 do
--   local label = GNUI.newLabel()
--
--   label:setText("Lorem ipsum, dolor sit amet consectetur adipisicing elit")
--   label:setWrapText(true)
--   label:setDimensions(16,16,-16,-16)
--   label:setAnchor(0,0,1,1)
--   last:addChild(label)
--   last = label
--end