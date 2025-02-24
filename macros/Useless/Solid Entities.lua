
local side2dir = {
	north = vec(0,0,-1),
	east = vec(1,0,0),
	south = vec(0,0,1),
	west = vec(-1,0,0),
	up = vec(0,1,0),
	down = vec(0,-1,0)
}

local Macros = require("scriptHost.macros")

return Macros.new("Solid Entities",function (macro)
	local lvel = vec(0,0,0)
	function macro.TICK(df,dt)
		if player:isLoaded() then
			local psize = player:getBoundingBox()
			local checkSize = psize*vec(3,3,3)
			local ppos = player:getPos(dt)
			local pvel = player:getVelocity()
			local entities = world.getEntities(-checkSize+ppos,checkSize+ppos) ---@type Entity[]
			local aabb = {}
			for _, entity in ipairs(entities) do
				if entity:getUUID() ~= player:getUUID() then 
					local offset = entity:getBoundingBox()
					local pos = entity:getPos()
					local min = pos - (offset) * vec(0.5,0,0.5) - psize.xyz
					local max = pos + offset * vec(0.5,1,0.5) + psize.x_z
					aabb[#aabb+1] = {min,max}
				end
			end
			local _,hitpos,side,id = raycast:aabb(ppos,ppos+pvel,aabb)
			local normal = side2dir[side]
			if side then
				goofy:setPos(hitpos+normal*0.1)
				local evel = entities[id]:getVelocity()
				goofy:setVelocity(vec(table.unpack(player:getNbt().Motion)) * (vec(1,1,1)-normal) + (evel - pvel.x_z))
				lvel = evel
				if host:isJumping() then
					goofy:setVelocity(vec(table.unpack(player:getNbt().Motion)) + vec(0,0.45,0))
				end
			end
		end
	end
end),"Duplicates the player modelPart and squishes it onto the ground"