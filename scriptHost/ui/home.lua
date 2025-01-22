local GNUI = require("lib.GNUI.main")
local Pages = require"lib.pages"
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

local ICON_SCALE = 1
local MARGIN = 20
local WIDTH = 100

Pages.newPage("home",{},function (events, screen)
	local stack = GNUI.newBox(screen)
	stack:setAnchor(0.5,0,0.5,1):setDimensions(MARGIN-WIDTH,MARGIN,-MARGIN+WIDTH,-MARGIN)
   for i = 1, #items, 1 do
      local item = items[i]
      local button = Button.new(stack)
		:setAnchor(0,0,1,0)
      :setSize(0,22)
		:setPos(0,(i-1)*25)
		
		:setTextAlign(0,0.5)
		:setTextOffset(25,0)
      :setText(item[2])
		
		button.PRESSED:register(function ()
         Pages.setPage(item[1])
      end)
		
      
      local icon = GNUI.newBox(button):setAnchor(0,0.5):setPos(12,-2)
      
      icon.ModelPart:newItem("icon"):item(item[3]):displayMode("GUI"):setScale(ICON_SCALE,ICON_SCALE,ICON_SCALE):setPos(0,0,-32)
      for j = 1, 8, 1 do
         local o = offset[j]
         icon.ModelPart:newItem("outline"..j):item(item[3]):displayMode("GUI"):setScale(ICON_SCALE,ICON_SCALE,ICON_SCALE):setPos(o.x,o.y,-16):setLight(0,0)
      end
   end
end)