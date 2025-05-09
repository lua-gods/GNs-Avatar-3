local LEFT_LEG = models.player.Base.LeftLeg
local RIGHT_LEG = models.player.Base.RightLeg
local LEFT_ARM = models.player.Base.Torso.LeftArm
local RIGHT_ARM = models.player.Base.Torso.RightArm
local BASE = models.player.Base

local floaty = 0

local spring = require"lib.spring"

local accel = vec(0,0,0)
local lvel = vec(0,0,0)
local vx = spring.new({f=0.6,z=0.4,r=2})
local vz = spring.new({f=0.6,z=0.4,r=2})

events.TICK:register(function ()
	local vel = vectors.rotateAroundAxis(player:getBodyYaw(delta), player:getVelocity(delta)*-25, vectors.vec3(0, 1, 0))
	accel = (vel - lvel)
	vx.target = accel.x * 10 + vel.x
	vz.target = accel.z * 10 + vel.z
	lvel = vel
	if player:isOnGround() or (player:isUnderwater()) or player:getVehicle() then
		if floaty > 0 then
			floaty = math.max(0, floaty - 0.2)
		end
	else
		if floaty < 1 then
			floaty = math.min(1, floaty + 0.05)
		end
	end
end)

local lastSystemTime = client:getSystemTime()
events.RENDER:register(function (delta, ctx, matrix)
	if ctx == "RENDER" then
		local systemTime = client:getSystemTime()
		local deltaFrame = (systemTime - lastSystemTime) / 1000
		lastSystemTime = systemTime
		if floaty >= 0 then
			spring.update(deltaFrame)
			local swing = vec(vz.pos,0,vx.pos) * floaty
			local swingRot = vanilla_model.LEFT_LEG:getOriginRot() * floaty
			LEFT_LEG:setRot(-swingRot+swing)
			RIGHT_LEG:setRot(swingRot+swing)
			
			LEFT_ARM:setRot(swingRot*0.7+swing)
			RIGHT_ARM:setRot(-swingRot*0.7+swing)
			BASE:setRot(swing)
		end
	end
end)