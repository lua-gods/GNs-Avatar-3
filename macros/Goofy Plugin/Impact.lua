local Macros = require("scriptHost.macros")

local POWER = 2
local combo = 0
local sinceLastCombo = 0
local sprint = keybinds:fromVanilla("key.sprint")
local sneak = keybinds:fromVanilla("key.sneak")


local function randomCircle()
	local theta = math.random() * math.pi * 2
	return vec(math.cos(theta),math.sin(theta))*math.random()
end


local endesga = require"lib.palettes.endesga64"

local COLORS = {
	endesga.brightGreen,
	endesga.lightGreen,
	endesga.green,
	endesga.darkGreen,
	endesga.darkerGreen
}




---@param dir Vector3
function pings.impact(dir)
	if not player:isLoaded() then return end
	local pos = player:getPos():add(0,player:getEyeHeight()*0.5,0)
	local dirx = vec(0,1,0.0001):cross(dir):normalize()
	local dirz = dir:cross(dirx):normalize()
	
	local mat = matrices.mat4(
		dirx:augmented(0)*2,
		dir:augmented(0)*2,
		dirz:augmented(0)*2,
		pos:augmented()
	)
	
	sounds:playSound("minecraft:entity.lightning_bolt.impact",pos,1,0.8)
	
	local origin = mat:apply()
	for i = 1, 200, 1 do
		local circ = randomCircle().xy_
		particles["end_rod"]
		:pos(origin)
		:velocity(mat:applyDir(circ))
		:color(COLORS[math.random(1,#COLORS)])
		:scale(1+math.random()*3)
		:lifetime(math.random(10,20))
		:spawn()
	end
	particles["flash"]:pos(origin):color(endesga.green):spawn()
end

return Macros.new("Impact",function (events)
   local cooldown = 0
	local isOnSurface = false
	local lvel = vec(0,0,0)
	function events.TICK()
		local vel = player:getVelocity()
		local accel = (vel - lvel)
		accel = vec(math.abs(accel.x),math.abs(accel.y),math.abs(accel.z))
		if cooldown < 0 and (accel.x > 0.5 or accel.y > 0.5 or accel.z > 0.5) and world.getBlockState(player:getPos() + vel:normalized()):hasCollision() then
			if not isOnSurface then
				local dir = vec(
					accel.x > accel.y and accel.x > accel.z and 1 or 0,
					accel.y > accel.x and accel.y > accel.z and 1 or 0,
					accel.z > accel.x and accel.z > accel.y and 1 or 0
				)
				pings.impact(dir)
				cooldown = 40
				isOnSurface = true
			end
		else
			if isOnSurface then
				isOnSurface = false
			end
		end
		cooldown = cooldown - 1
		lvel = vel
	end
end),"crashing onto a surface will cause an impact"