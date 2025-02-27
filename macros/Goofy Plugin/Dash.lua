local Macros = require("scriptHost.macros")

local POWER = 2
local combo = 0
local sinceLastCombo = 0
local sprint = keybinds:fromVanilla("key.sprint")
local sneak = keybinds:fromVanilla("key.sneak")


local endesga = require"lib.palettes.endesga64"


local COLORS = {
	endesga.brightGreen,
	endesga.lightGreen,
	endesga.green,
	endesga.darkGreen,
	endesga.darkerGreen
	}


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
		local clr = COLORS[math.random(1,#COLORS)]
		particles["end_rod"]:pos(ppos):spawn():color(clr):velocity(dir*math.random()):lifetime(math.random(20,50))
	end
end

return Macros.new("Dash",function (events)
   sneak.press = function ()
		if sprint:isPressed() then
			local time = client:getSystemTime()
			if time - sinceLastCombo < 500 then
				combo = combo + 1
			else
				combo = 0
			end
			sinceLastCombo = time
			local force = player:getLookDir() * (POWER + combo)
			renderer:setFOV(1.1)
			wait(50,function ()
				renderer:setFOV(1)
				wait(50,function ()
					renderer:setFOV()
				end)
			end)
			pings.macroDash(force)
			goofy:setVelocity(force)
			return true
		end
	end
	function events.EXIT()
		sneak.press = nil
	end
end),"Pressing [Ctrl] + [Shift] will make the player dash"