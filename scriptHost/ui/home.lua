local GNUI = require("lib.GNUI.main")
local Pages = require"lib.pages"
local GridStacker = require"lib.GNUI.element.gridStacker"
local Button = require"lib.GNUI.element.button"
local Slider = require"lib.GNUI.element.slider"

local offset = {
   vec(-1,1),
   vec(0,1),
   vec(1,1),
   vec(1,0),
   vec(1,-1),
   vec(0,-1),
   vec(-1,-1),
   vec(-1,0),
}

---@type {[1]:string,[2]:string,[3]:Minecraft.itemID}[]
local items = {
   {"nameplate","Nameplate","minecraft:name_tag"},
--   {"pageEditor","Page Editor","minecraft:map"},
   {"avatarStore","Avatar Store Viewer","minecraft:skull_banner_pattern"},
   {"mailman","Mailman Test","minecraft:paper"},
   {"testPage","Testing Page","minecraft:piston"},
--   {"chloePiano","Chloe Piano","minecraft:player_head{SkullOwner:\"ChloeSpacedIn\"}"},
--   {"unitTest","GUI Unit Tests","minecraft:ender_eye"},
}

local page = Pages.newPage("home")
---@param box GNUI.Box
page.INIT:register(function (box)
   local grid = GridStacker.new(vec(70,80),box)
   grid
   :setAnchor(0.5,0,0.5,1)
   :setDimensions(-70*3,64,70*3,-64)
   for i = 1, #items, 1 do
      local area = GNUI.newBox(grid)
      :setSize(70,80)
      local item = items[i]
      local button = Button.new(area)
      :setDimensions(10,5,60,55)
      button.PRESSED:register(function ()
         Pages.setPage(item[1])
      end)
      local label = GNUI.newBox(area)
      :setAnchor(0,1,1,1):setDimensions(0,-25,0,0)
      :setText(item[2])
      :setTextBehavior("WRAP")
      :setTextAlign(0.5,0.5)
      :setTextEffect("OUTLINE")
      :setCanCaptureCursor(false)
      
      local icon = GNUI.newBox(button):setAnchor(0.5,0.5)
      
      icon.ModelPart:newItem("icon"):item(item[3]):displayMode("GUI"):setScale(2.5,2.5,2.5):setPos(0,0,-32)
      for j = 1, 8, 1 do
         local o = offset[j]
         icon.ModelPart:newItem("outline"..j):item(item[3]):displayMode("GUI"):setScale(2.5,2.5,2.5):setPos(o.x,o.y,-16):setLight(0,10)
      end
   end
end)
