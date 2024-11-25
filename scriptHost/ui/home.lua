local GNUI = require("lib.GNUI.main")

local Pages = require"lib.pages"
local GridStacker = require"lib.GNUI.element.GridStacker"
local Button = require"lib.GNUI.element.button"

---@type {[1]:string,[2]:string,[3]:Minecraft.itemID}[]
local items = {
   {"nameplate","Nameplate","minecraft:nametag"},
   {"pageEditor","Page Editor","minecraft:map"},
}

local page = Pages.newPage("home")
---@param box GNUI.Box
page.INIT:register(function (box)
   local grid = GridStacker.new(vec(120,20),box)
   grid
   :setAnchor(0.5,0,0.5,1)
   :setDimensions(-205,64,205,-64)
   :setSpacing(8,8)
   for i = 1, #items, 1 do
      local item = items[i]
      Button.new(grid)
      :setSize(120,20)
      :setText(item[2])
      .PRESSED:register(function ()
         Pages.setPage(item[1])
      end)
   end
end)