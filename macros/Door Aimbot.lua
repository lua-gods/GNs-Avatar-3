local side2dir = {
   north = vec(0,0,-1),
   east = vec(1,0,0),
   south = vec(0,0,1),
   west = vec(-1,0,0),
   up = vec(0,1,0),
   down = vec(0,-1,0)
}

local active = false
local hadDoorPos
macro.tick = function ()
   local ppos = player:getPos()
   local blockin = world.getBlockState(ppos)
   local fr = false
   if blockin.id:find("_door$") then
      fr = true
   else
      if hadDoorPos and (hadDoorPos.xz-ppos.xz):length() < 2 then
         fr = true
         blockin = world.getBlockState(hadDoorPos)
         ppos = hadDoorPos
      else
         hadDoorPos = nil
      end
   end
   if fr then
      hadDoorPos = ppos
      active = true
      local dir = side2dir[blockin.properties.facing] * -0.4
      if blockin.properties.hinge == "right" then
         dir = dir + vectors.rotateAroundAxis(90,dir,vec(0,1,0))
      else
         dir = dir + vectors.rotateAroundAxis(-90,dir,vec(0,1,0))
      end
      local epos = ppos:floor():sub(player:getPos()):add(0.5,0,0.5) + dir
      renderer:setEyeOffset(epos)
      particles["end_rod"]:scale(1):lifetime(1):pos(client:getCameraPos():add(epos))
   else
      if active then
         renderer:setEyeOffset()
         active = false
      end
   end
end
