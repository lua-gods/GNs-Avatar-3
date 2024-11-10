--[[______   __
	/ ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / Experimental Physics test
/ /_/ / /|  / very WIP
\____/_/ |_/ Source: link]]

local endesga = require"palettes.endesga64"
local Line = require"libraries.line"

local MARGIN = 0.001

local modelWorld = models:newPart("modelWorld","WORLD")


local side2dir = {
	north = vec(0,0,-1),
	east = vec(1,0,0),
	south = vec(0,0,1),
	west = vec(-1,0,0),
	up = vec(0,1,0),
	down = vec(0,-1,0)
}

local cubePoints = {}

for z = -0.5, 0.5, 0.5 do
	for y = -0.5, 0.5, 0.5 do
		for x = -0.5, 0.5, 0.5 do
			cubePoints[#cubePoints+1] = vec(x,y,z)
		end
	end
end


---projects dir into the normal
---@param vector Vector3
---@param normal Vector3
local function flatten(vector, normal)
	normal = normal:normalized()
	return vector - vector:dot( normal) * normal
end

---@class RigidBody
---@field static boolean
---@field origin Vector3
---
---@field pos Vector3
---@field vel Vector3
---
---@field rvel Vector3
---@field rot Matrix3
---
---@field invInertia Vector3
---@field mass number
---@field size Vector3
---@field volume number
---
---@field model ModelPart
---@field lines table<string,Line>
---@field lastTransform Matrix4
---@field transform Matrix4
local RigidBody = {}
RigidBody.__index = RigidBody
local bodies = {} ---@type RigidBody[]


---@param data {pos:Vector3?,rot:Vector3?,size:Vector3?,block:string?,static:boolean?,vel:Vector3?,rvel:Vector3?,density:number?}
---@return RigidBody
function RigidBody.new(data)
	data = data or {}
	local pos = data.pos or vec(0,0,0)
	local rot = data.rot or vec(0,0,0)
	local size = data.size or vec(1,1,1)
	local block = data.block or "minecraft:grass_block"

	local d = size*size
	
	local model = modelWorld:newPart("Body")
	local i = 0
	local csize = size:copy():ceil()
	for z = 1, csize.z, 1 do
		for y = 1, csize.y, 1 do
			for x = 1, csize.x, 1 do
				i = i + 1
				local dsize = vec(
					math.min(size.x - (x-1),1),
					math.min(size.y - (y-1),1),
					math.min(size.z - (z-1),1)
				)
				local bpos = vec((x-dsize.x),(y-dsize.y),(z-dsize.z))*16 - size * 8
				model:newBlock("block"..i):block(block)
				:pos(bpos)
				:scale(dsize)
			end
		end
	end
	
	local density = data.static and math.huge or (data.density or 1)
	
	local inertia = (size.x * size.y * size.z) * vec(d.y+d.z, d.x+d.z, d.x+d.y) / 12 * density
	
	local body = {
		model = model,
		origin = pos or vec(0,0,0),
		pos = pos or vec(0,4,0),
		vel = data.vel or vec(0,0,0),
		rvel = data.rvel or vec(0,0,0),
		rot = matrices.mat3(),
		invInertia = vec(1,1,1) / inertia,
		density = density,
		mass = size.x * size.y * size.z * density,
		size = size,
		static = data.static or false,
		volume = size.x * size.y * size.z,
		lines = {
			x = Line.new():setColor(endesga.red),
			y = Line.new():setColor(endesga.green),
			z = Line.new():setColor(endesga.blue),
			l = Line.new():setColor(endesga.lightBlue),
			o = Line.new():setColor(endesga.pinkRed),
			v = Line.new():setColor(endesga.orange),
			hit = Line.new():setColor(endesga.violet),
		}
	}
	for key, l in pairs(body.lines) do l:setWidth(0.05) end
	if rot then
		body.rot:rotate(rot)
	end
	setmetatable(body,RigidBody)
	bodies[#bodies+1] = body
	return body
end


---@param pos Vector3
---@param vel Vector3
function RigidBody:applyImpulseForce(pos,vel)
	local offset = pos - self.pos
	local impulse = vel
	self.vel = self.vel + impulse
	local torque = offset:normalized():cross(impulse:normalized()) / offset:length() * impulse:length() * self.invInertia * 100
	self.rvel = self.rvel + torque
	
	particles["end_rod"]:pos(pos):color(endesga.red):velocity(vel):gravity(0):spawn()
end

local function reflect(dir,normal)
	return dir - 2 * dir:dot(normal) * normal
end

local substeps = 1

local lastSystemTime = client:getSystemTime()
events.WORLD_RENDER:register(function (dt)
	local systemTime = client:getSystemTime()
	local delta = (systemTime - lastSystemTime) / 1000
	lastSystemTime = systemTime
	delta = delta / substeps
	for step = 1, substeps, 1 do
		
		for key, body in pairs(bodies) do
			if not body.static then
	
				-- simulation
				body.pos = body.pos + body.vel * delta
	
				local invInertia = matrices.mat3(
					vec(body.invInertia.x,0,0),
					vec(0,body.invInertia.y,0),
					vec(0,0,body.invInertia.z)
				)
	
				local omega = (body.rot * invInertia * body.rot:transposed()) * (body.rvel:length() ~= 0 and body.rvel or vec(0,0.000001,0))
				local speed = math.deg(omega:length()) * delta
				body.lrot = body.rot:copy()
				body.rot.c1 = vectors.rotateAroundAxis(speed,body.rot.c1,omega)
				body.rot.c2 = vectors.rotateAroundAxis(speed,body.rot.c2,omega)
				body.rot.c3 = vectors.rotateAroundAxis(speed,body.rot.c3,omega)
	
				-- damp
				--body.rvel = body.rvel * 0.95
				--body.vel = body.vel * 0.95
				body.vel = body.vel + vec(0,-0.05,0)
	
				-- interaction
				if player:isLoaded() then
					local mat = matrices.mat4(
						body.rot.c1.xyz_:normalized(),
						body.rot.c2.xyz_:normalized(),
						body.rot.c3.xyz_:normalized(),
						(body.pos):augmented(1)
					)
					local invMat = mat:inverted()
	
					local ppos = player:getPos(dt):add(0,player:getEyeHeight())
					local pdir = player:getLookDir()
					local aabb,hitPos,side = raycast:aabb(
					invMat:apply(ppos),
					invMat:apply(ppos+pdir*10),
					{{body.size * -0.5,body.size * 0.5}})
					local hitDir = mat:applyDir(side2dir[side])
					if hitPos then
						hitPos = mat:apply(hitPos)
						body.lines.hit:setAB(hitPos,hitPos+hitDir)
						if player:getSwingTime() == 1 then
							body:applyImpulseForce(hitPos,-hitDir*1)
						end
					else
						body.lines.hit:setAB(vec(0,0,0),vec(0,0,0))
					end
				end
	
				local omegaDir = omega:normalized()
				body.lines.o:setAB(body.pos-omegaDir*2,body.pos+omegaDir*2)
			end
			-- rendering
			local rMat = body.rot:augmented():translate(body.pos * 16)
			body.model:setMatrix(rMat)
	
			-- debug
			local rvelDir = body.rvel:length() ~= 0 and body.rvel:normalized() or vec(0,1,0)
			body.lines.x:setAB(body.pos,body.pos+body.rot.c1 * 1.5)
			body.lines.y:setAB(body.pos,body.pos+body.rot.c2 * 1.5)
			body.lines.z:setAB(body.pos,body.pos+body.rot.c3 * 1.5)
			body.lines.l:setAB(body.pos-rvelDir*2,body.pos+rvelDir*2)
			body.lines.v:setAB(body.pos-body.vel*2,body.pos+body.vel*2)
	
			-- cache
			local mat = matrices.mat4(
				body.rot.c1.xyz_*body.size.x,
				body.rot.c2.xyz_*body.size.y,
				body.rot.c3.xyz_*body.size.z,
				(body.pos):augmented(1)
			)
			body.lastTransform = body.transform
			body.transform = mat
			body.invTransform = mat:inverted()
		end
	
		---@type {a: RigidBody, b: RigidBody, hitPos: Vector3, dir: Vector3, offset: Vector3}[]
		local collisions = {}
	
		for iA, bodyA in pairs(bodies) do
			if bodyA.lastTransform then
				local matA = bodyA.transform
	
				for iB, bodyB in pairs(bodies) do
					if iA ~= iB then
						local matB = bodyB.transform
						local invMatB = matB:inverted()
						local collisionPoints = {}
	
						for i = 1, #cubePoints, 1 do
							local offset = cubePoints[i]
							local a = invMatB:apply(matA:apply(offset))
							if a.x >= -0.5 and a.y >= -0.5 and a.z >= -0.5
							and a.x <= 0.5 and a.y <= 0.5 and a.z <= 0.5 then
								-- colliding
								local aabb,hitPos,side = raycast:aabb(invMatB:apply(matA.c4.xyz),a,{{vec(-0.5,-0.5,-0.5),vec(0.5,0.5,0.5)}})
								local hitDir = matB:applyDir(side2dir[side])
								local vel = bodyA.transform:apply(offset) - bodyA.lastTransform:apply(offset)
								collisionPoints[#collisionPoints+1] = {hitpos = matB:apply(hitPos),offset = offset, dir = hitDir,vel=vel}
							end
						end
	
						if #collisionPoints > 0 then
							local midPos = vec(0,0,0)
							local midDir = vec(0,0,0)
							local midOffset = vec(0,0,0)
							local midVel = vec(0,0,0)
							for i = 1, #collisionPoints, 1 do
								local p = collisionPoints[i]
								midPos = midPos + p.hitpos
								midDir = midDir + p.dir
								midOffset = midOffset + p.offset
								midVel = midVel + p.vel
							end
							local amount = #collisionPoints
							midPos = midPos / amount
							midDir = midDir / amount
							midOffset = midOffset / amount
							midVel = midVel / amount
							collisions[#collisions+1] = {
								a=bodyA,
								b=bodyB,
								hitPos = midPos,
								dir = midDir,
								offset = midOffset
							}
						end
					end
				end
			end
		end
		host:setActionbar("Collisions: "..#collisions)
		-- handling collisions
		
		for i = 1, #collisions, 1 do
			local data = collisions[i]
			local bodyA = data.a
			local bodyB = data.b
			local hitDir = data.dir
			local Apos = bodyB.transform:apply(data.offset)
			local hitPos = data.hitPos
			
			local massRatio
			if bodyA.static then
				massRatio = 1
			elseif bodyB.static then
				massRatio = 0
			else
				massRatio = bodyA.mass / (bodyA.mass + bodyB.mass)
			end
			
			
			local velA = (bodyA.transform - bodyA.lastTransform):apply(data.offset)
			local velB = (bodyB.transform - bodyB.lastTransform):apply(data.offset)
			
			local avel = velA - velB
			local bvel = -avel
			
			-- flatten velocity
			local favel = flatten(avel,hitDir)
			local fbvel = flatten(bvel,hitDir)
			
			-- flatten impulse
			local davel = (avel - favel)
			local dbvel = (bvel - fbvel)
			
			local friction = 4
			local restitution = 1
			
			local AinvMat = bodyA.transform:inverted()
			
			local invMassRatio = (1-massRatio)
			local pos = bodyA.transform:apply(data.offset)
			local posShifted = flatten(pos - hitPos,hitDir)+hitPos + hitDir * MARGIN
			local push = (posShifted - pos)
			bodyA.pos = bodyA.pos + push * 2 * invMassRatio
			
			bodyA:applyImpulseForce(pos,fbvel * friction)
			bodyA.vel = flatten(bodyA.vel - bodyB.vel,hitDir) + flatten(bodyB.vel,hitDir)
			bodyA:applyImpulseForce(pos,dbvel * invMassRatio)
			
			
			if not bodyB.static then
				local Bpush = flatten(pos - hitPos,hitDir)+hitPos - hitDir * MARGIN
				bodyB.pos = bodyB.pos - push * 2 * massRatio
				bodyB:applyImpulseForce(pos,favel * friction)
				bodyB.vel = flatten(bodyB.vel - bodyA.vel,hitDir) + flatten(bodyA.vel,hitDir)
				bodyB:applyImpulseForce(pos,davel * massRatio)
			end
		end
	end
end)






for i = 1, 20, 1 do
	local body = RigidBody.new({
		density = 1,
		size = vec(2,2,2),
		pos = vec(math.random(-4,4),8+i*3,math.random(-4,4)),
		vel = vec(0,0,0),
		block="gold_block"
	})
end


local body2 = RigidBody.new({
	density = 1,
	size = vec(10,1,10),
	pos = vec(0,3,0),
	rot = vec(0,0,0),
	vel = vec(0,0,0),
	block="diamond_block",
	static = true
})