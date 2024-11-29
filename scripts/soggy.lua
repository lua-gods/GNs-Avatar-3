local stats = require"lib.playerStats"

local lerp = math.lerp
local random = math.random

local function rand(a,b)
   return lerp(a,b,random())
end

events.TICK:register(function ()
   local ppos = player:getPos()
   local bb = player:getBoundingBox():mul(0.5,1,0.5)
   
   local particlePos = ppos:add(rand(-bb.x,bb.x),rand(0,bb.y),rand(-bb.z,bb.z))
   local wetness = stats.wetness
   if wetness > 0 and wetness ~= 1 then
      if wetness > random() then
         particles["minecraft:falling_water"]:pos(particlePos):spawn()
      end
   end
end)