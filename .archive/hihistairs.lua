function events.TICK()
   local ppos = player:getPos()
   local psize = player:getBoundingBox().x_z*0.4999
   local blocks = world.getBlocks(ppos-psize-vec(0,1,0), ppos+psize)
   
   local aabb = {}
   for i = 1, #blocks, 1 do
      local block = blocks[i]
      local hitbox = block:getCollisionShape()
      local bpos = block:getPos()
      -- expand hitbox
      for j = 1, #hitbox, 1 do
         local box = hitbox[j]
         aabb[#aabb+1] = {
            box[1] - psize + bpos,
            box[2] + psize + bpos
         }
      end
   end
   local _,hitpos = raycast:aabb(ppos + vec(0,1,0),ppos - vec(0,1,0),aabb)
   local height
   if hitpos then
      particles:newParticle("minecraft:end_rod",hitpos)
      height = ppos.y - hitpos.y
   else
      height = 1
   end
   
   host:setActionbar(("height %.1f"):format(height))
   
   local count = 0
   while aabb[count] do
      count = count + 1
   end
end