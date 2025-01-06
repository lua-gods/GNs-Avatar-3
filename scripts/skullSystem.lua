
local HEAD_UNRENDERED_TIMEOUT = 50

local UP = vec(0,1,0)
local FACE_2_DIR = {
   south = vec(0,0,1),
   west = vec(-1,0,0),
   north = vec(0,0,-1),
   east = vec(1,0,0)
}

local FACE_2_ROT = {
   south = 0,
   west = 90,
   north = 180,
   east = 270
}

local worldPart = models:newPart("GN.skullSystem","Skull")
worldPart:newBlock("gras"):block("minecraft:grass_block")

local skulls = {}


local time = client:getSystemTime()
local lastTimeCheck = time
local headRenderCount = 0
events.WORLD_RENDER:register(function ()
   headRenderCount = 0
   time = client:getSystemTime()
   
   if lastTimeCheck + HEAD_UNRENDERED_TIMEOUT < time then
      lastTimeCheck = time
      
      -- check for every skull if they havent been rendered for a while
      for id, skull in pairs(skulls) do
         if skull.lastCheck + HEAD_UNRENDERED_TIMEOUT < time then
            skulls[id] = nil
         end
      end
   end
end)

events.SKULL_RENDER:register(function (delta, block, item, entity, ctx)
   local isBlock = ctx:find("^B") and true
   worldPart:setVisible(false)
	if isBlock then -- block
		local pos = block:getPos()
		local id = ("%s,%s,%s"):format(pos.x, pos.y, pos.z)
		local skull = skulls[id]
		
		local dir
		local rot = 0
      local offset
		
		if skull then -- check if the skull is registered
			dir = skull.dir
			rot = skull.rot
         offset = skull.offset
         skull.lastCheck = time
		else
			if block.id == "minecraft:player_wall_head" then
				dir = FACE_2_DIR[block.properties.facing]
				rot = FACE_2_ROT[block.properties.facing]
            offset = vec(0,0,0)
			else
				dir = UP
				rot = tonumber(block.properties.rotation) * 22.5
            offset = vec(8,0,8)
			end
			skull = {
				dir = dir,
				rot = rot,
				id = id,
				pos = pos,
            offset = offset,
            lastCheck = time
			}
			skulls[id] = skull
		end
      
      headRenderCount = headRenderCount + 1
      if headRenderCount == 1 then -- first render
         local rad = -math.rad(rot)
         local fpos = pos * 16 + offset
         worldPart:setPos(vec(
            (math.sin(rad) * fpos.z - math.cos(rad) * fpos.x),
            fpos.y,
            (-math.cos(rad) * fpos.z - math.sin(rad) * fpos.x)
         )):setRot(0,rot,0)
         worldPart:setVisible(true)
      end
	end
end)