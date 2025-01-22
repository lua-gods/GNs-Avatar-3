local GNUI = require("lib.GNUI.main")
local Pages = require"lib.pages"
local use = keybinds:fromVanilla("key.use")
local zoom = 0.2
local isActive = false

local page = Pages.newPage("spyglass",{bgOpacity=0,unlockCursor=false},function (events, screen)
	screen.zoomBox = GNUI.newBox(screen)
   :setAnchor(0,1,1,1)
   :setPos(0,-50)
   :setText("hello")
   :setTextAlign(0.5,0.5)
   :setTextEffect("OUTLINE")
   :setSize(0,20)
	
	function events.TICK()
		screen.zoomBox:setText("Zoom: x"..(math.floor(1/zoom * 10) / 10))
	end
end)


events.TICK:register(function ()
   if player:getHeldItem().id == "minecraft:spyglass" then
      if use:isPressed() then
         if not isActive then
            isActive = true
            Pages.setPage("spyglass")
         end
         renderer:setFOV(zoom)
      else
         if isActive then
            isActive = false
            Pages.returnPage()
         end
         renderer:setFOV()
      end
   end
end)

events.MOUSE_SCROLL:register(function (dir)
   if isActive then
      zoom = zoom * (dir * -0.1 + 1)
      renderer:setFOV(zoom)
      return true
   end
end)