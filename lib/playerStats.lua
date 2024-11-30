local eventLib = require"lib.eventLib"

local stats = {
   wetness = 0,
   UPDATE = eventLib.new(),
}

local timer = 0
events.TICK:register(function ()
   
   timer = timer + 1
   if timer > 10 then
      timer = 0
      -- Water
      if player:isUnderwater() then stats.wetness = 1
      else stats.wetness = math.max(stats.wetness - 0.05,0)
      end
      stats.UPDATE:invoke()
   end
end)

return stats