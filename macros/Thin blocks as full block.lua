
local side2dir = {
   north = vec(0,0,-1),
   east = vec(1,0,0),
   south = vec(0,0,1),
   west = vec(-1,0,0),
   up = vec(0,1,0),
   down = vec(0,-1,0)
}

local SUBSTEPS = 16

local whitelist = {
   "glass_pane$",
   "minecraft:iron_bars"
}

local selection = models:newPart("Thinblocksasfullblock","WORLD"):light(15,15)
selection:newBlock("display"):block("minecraft:white_stained_glass")

local active = false

macro.tick = function ()
   local cpos = player:getPos():add(0,player:getEyeHeight())
   local bpos = cpos:copy()
   local rdir = player:getLookDir() / SUBSTEPS
   local activated = false
   for _ = 1, host:getReachDistance()*SUBSTEPS, 1 do
      bpos = bpos + rdir
      local block = world.getBlockState(bpos)
      if block:hasCollision() then
         local isValid = false
         for i = 1, #whitelist, 1 do
            if block.id:find(whitelist[i]) then
               isValid = true
               break
            end
         end
         if isValid then
            bpos = bpos:floor()
            local _, hitpos, side = raycast:aabb((cpos-bpos),rdir:normalized()*10,{
               {vec(0,0,0),
               vec(1,1,1)}
            })
            if side then
               local shape = block:getOutlineShape()[1]
               local size = (shape[1]-shape[2])
               size.x,size.y,size.z = math.abs(size.x), math.abs(size.y), math.abs(size.z)
               local gpos = bpos:copy():add(math.lerp(shape[1],shape[2],0.5) + size * side2dir[side] * 0.5):sub(rdir:normalized()*0.05)
               renderer:setEyeOffset(gpos - cpos)
               activated = true
               active = true
               selection:pos(bpos * 16):visible(true)
            end
            break
         end
      end
   end

   if not activated and active then
      active = false
      selection:visible(false)
      renderer:setEyeOffset()
   end
end
