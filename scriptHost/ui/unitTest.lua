local GNUI = require("lib.GNUI.main")

local Pages = require"lib.pages"
local Button = require"lib.GNUI.element.button"

local page = Pages.newPage("unitTest")
---@param box GNUI.Box
page.INIT:register(function (box)
   local testBox = GNUI.newBox(box)
   :setTextBehavior("WRAP")
   :setFontScale(0.25)
   :setText("Lorem ipsum dolor sit amet consectetur adipisicing elit. Doloremque magni sapiente facere libero saepe necessitatibus sit aperiam veniam pariatur in expedita, quae asperiores alias adipisci impedit, sint, velit porro similique?")
   events.WORLD_RENDER:register(function (delta)
      local t = client:getSystemTime()/500
      testBox
      :setPos(math.sin(t)+30,math.cos(t)+50)
      :setSize(math.sin(t)*50+100,math.cos(t)*50+70)
   end)
end)