local animLib = require("lib.GNanim")

local isIdle = false
local alive = 40

if IS_HOST then
   local wasIdle = false
   local timer = 0
   events.WORLD_TICK:register(function ()
      local idle = not client:isWindowFocused()
      if idle ~= wasIdle then
         wasIdle = idle
         pings.idle(idle)
      end
      timer = timer + 1
      if timer > 40 then
         timer = 0
         pings.idle(idle)
      end
   end)
end

local function setIdle(state)
   alive = 60
   if isIdle ~= state then
      isIdle = state
      if isIdle then
         animations.player.newspaperInit:stop()
         animations.player.newspaperOutro:stop()
         animations.player.newspaperIntro:play()
      else
         animations.player.newspaperIntro:stop()
         animations.player.newspaperOutro:play()
      end
   end
end

events.TICK:register(function ()
   alive = alive - 1
   if alive <= 0 then
      alive = 60
      setIdle(true)
   end
   if not host:isHost() then
      if player:getVelocity().xz:length() > 0.1 then
         alive = 60
      end
   end
end)

models.player.Newspaper:setVisible(true)
animations.player.newspaperInit:play()
function pings.idle(state)
   setIdle(state)
end

