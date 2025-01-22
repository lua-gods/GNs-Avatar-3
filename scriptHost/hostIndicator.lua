local GNUI = require"lib.GNUI.main"
local screen = GNUI.getScreenCanvas()

local b = GNUI.newBox(screen)
:setAnchor(0,1,0,1)
:setPos(5,-23):setSize(100,10)
:setText({text="Avatar is Local"})
:setTextEffect("OUTLINE")

events.WORLD_TICK:register(function ()
  if host:isAvatarUploaded() then
    b:free()
    events.WORLD_TICK:remove("uploaded_checker")
  end
end,"uploaded_checker")