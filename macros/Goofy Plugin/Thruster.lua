local Macros = require("lib.macros")

local POWER = 2

local sprint = keybinds:fromVanilla("key.sprint")
local sneak = keybinds:fromVanilla("key.sneak")

function pings.macroDash(dir)
	if not player:isLoaded() then return end
	local pos = player:getPos()
	local size = player:getBoundingBox()
	sounds:playSound("minecraft:entity.evoker.cast_spell",pos,1,1)
	sounds:playSound("minecraft:entity.illusioner.mirror_move",pos,1,1)
	sounds:playSound("minecraft:particle.soul_escape",pos,1,1)
	sounds:playSound("minecraft:particle.soul_escape",pos,1,0.5)
	
	for i = 1, 500, 1 do
		local ppos = pos + 
		vec(math.map(math.random(),-0.5,1.5,-size.x,size.x),
			math.map(math.random(),0,1,0,size.y),
			math.map(math.random(),-0.5,1.5,-size.z,size.z)
		)
		particles["end_rod"]:pos(ppos):spawn():velocity(dir*math.random()):lifetime(20)
	end
end

return Macros.new("Thruster",function (events)
	
   sneak.press = function ()
		if sprint:isPressed() then
			local force = player:getLookDir() * POWER
			pings.macroDash(force)
			goofy:setVelocity(force)
			return true
		end
	end
	function events.EXIT()
		jump.press = nil
	end
end),"Holding the Jump button will make the player levitate"