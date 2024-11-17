local GNUI = require("GNUI.main")

local Pages = require"libraries.pages"
local GridStacker = require"GNUI.element.GridStacker"
local Button = require"GNUI.element.button"

local page = Pages.newPage("home")
---@param box GNUI.Box
page.INIT:register(function (box)
   local grid = GridStacker.new(vec(120,20),box)
   grid
   :setAnchor(0.5,0,0.5,1)
   :setDimensions(-205,64,205,-64)
   :setSpacing(8,8)
   for i = 1, 10, 1 do
      Button.new(grid):setSize(120,20)
   end
end)