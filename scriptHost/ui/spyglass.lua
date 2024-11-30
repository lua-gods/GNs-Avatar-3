local Pages = require"lib.pages"

local use = keybinds:fromVanilla("key.use")
local zoom = 0.2
local isActive = false

local page = Pages.newPage("spyglass",{bgOpacity=0,unlockCursor=false})
page.INIT:register(function ()
   
end)

events.TICK:register(function ()
   if use:isPressed() and player:getHeldItem().id == "minecraft:spyglass" then
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
end)

events.MOUSE_SCROLL:register(function (dir)
   if isActive then
      zoom = zoom * (dir * -0.1 + 1)
      renderer:setFOV(zoom)
      return true
   end
end)