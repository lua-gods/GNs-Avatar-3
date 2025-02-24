local Macros = require("scriptHost.macros")

local interact = keybinds:newKeybind("Wand","key.mouse.right")

function pings.STE_poof(pos)
	if player:isLoaded() then
		particles["flash"]:pos(pos):spawn()
		sounds:playSound("minecraft:entity.firework_rocket.blast",pos,1,1)
	end
end

return Macros.new("StickTPsEntities",function (events)
	local holdingEntity
   interact.press = function ()
		if player:getHeldItem().id == "minecraft:stick" then
			local origin = player:getPos():add(0,player:getEyeHeight())
			local entity,entityHitPos = player:getTargetedEntity()
			local block,blockHitPos = player:getTargetedBlock()
			if not holdingEntity and (entity and (origin-entityHitPos):lengthSquared() or math.huge) < (origin-blockHitPos):lengthSquared() then
				holdingEntity = entity
				pings.STE_poof(entity:getPos():add(0,entity:getBoundingBox().y/2))
			else
				if holdingEntity then
					if not entity then
						host:sendChatCommand(("tp %s %.2f %.2f %.2f"):format(holdingEntity:getUUID(),blockHitPos:unpack()))
						pings.STE_poof(blockHitPos)
					end
				end
				holdingEntity = nil
			end
		end
	end
	function events.EXIT()
		interact.press = nil
	end
end),"clicking with a stick does magic TPs"