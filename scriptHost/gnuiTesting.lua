local GNUI = require("libraries.gnui")
local gnui_extras = require("libraries.gnui.modules.elements")
local gnui_window = require("libraries.gnui.modules.windows")

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


--local stack = gnui_extras.newStack()
--events.WORLD_RENDER:register(function (delta)
--   local o = (math.sin(client:getSystemTime() / 500) * 0.5 + 0.5) * 16
--   stack:setDimensions(0+o,0,64+o,128)
--end)
--for i = 1, 5, 1 do
--   local button = gnui_extras.newTextButton()
--   stack:addChild(button)
--   button:setPos(16,16):setSize(64,0)
--   button:setText("Hello World")
--   button.PRESSED:register(function ()
--   end)
--end
--
--stack:setCustomMinimumSize(64,64)
--stack:setPos(64,64)
--
--screen:addChild(stack)



--events.WORLD_TICK:register(function ()
--   local t = client:getSystemTime() / 500
--   button:setPos(64,64):setSize((math.sin(t) * 0.5 + 0.6) * 64,1)
--end)--

--local last = screen
--for i = 1, 7, 1 do
--   --do
--   --   local label = GNUI.newLabel()
--   --   label:setText("Lorem ipsum, dolor sit amet consectetur adipisicing elit")
--   --   label:setWrapText(true)
--   --   label:setDimensions(16,16,-16,-16)
--   --   label:setAnchor(0,0,1,1)
--   --   last:addChild(label)
--   --end
--   do
--      local label = GNUI.newLabel()
--
--      label:setText("Lorem ipsum, dolor sit amet consectetur adipisicing elit")
--      label:setWrapText(true)
--      label:setDimensions(16,16,-16,-16)
--      label:setAnchor(0,0,1,1)
--      last:addChild(label)
--      last = label
--   end
--end


for i = 1, 1, 1 do
   local window = gnui_window.newWindow()
   window:setSize(math.random(64,100),math.random(64,100))
   window:setPos(math.random(1,300),math.random(1,200))
   screen:addChild(window)
end

--goofy:setDisableGUIElement("CHAT",true)

-- EXTREME CONFUSION PROTOCOL
--events.RENDER:register(function ()
--   screen.ModelPart:setParentType("HUD")
--end)
--
--events.SKULL_RENDER:register(function (delta, block, item, entity, ctx)
--   if ctx == "BLOCK" then
--      screen.ModelPart:setParentType("SKULL")
--   end
--end)