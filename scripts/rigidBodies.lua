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
  local inertia = (size.x * size.y * size.z) * vec(d.y+d.z, d.x+d.z, d.x+d.y) / 12
  
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
  
  local body = {
    model = model,
    origin = pos or vec(0,0,0),
    pos = pos or vec(0,4,0),
    vel = data.vel or vec(0,0,0),
    rvel = data.rvel or vec(0,0,0),
    rot = matrices.mat3(),
    invInertia = vec(1,1,1) / inertia,
    density = data.density or 1,
    mass = size.x * size.y * size.z * (data.density or 1),
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
  local torque = offset:normalized():cross(impulse:normalized()) / offset:length() * impulse:length()
  self.rvel = self.rvel + torque
end

local function reflect(dir,normal)
  return dir - 2 * dir:dot(normal) * normal
end


local lastSystemTime = client:getSystemTime()
events.WORLD_RENDER:register(function (dt)
  local systemTime = client:getSystemTime()
  local delta = (systemTime - lastSystemTime) / 1000
  lastSystemTime = systemTime
  
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
      --body.vel = body.vel + vec(0,-0.1,0)
      
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
      
      local mat = matrices.mat4(
        body.rot.c1.xyz_:normalized(),
        body.rot.c2.xyz_:normalized(),
        body.rot.c3.xyz_:normalized(),
        (body.pos):augmented(1)
      )
      
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
  end
  
  for iA, bodyA in pairs(bodies) do
    if not bodyA.static then
      local matA = matrices.mat4(
        bodyA.rot.c1.xyz_*bodyA.size.x,
        bodyA.rot.c2.xyz_*bodyA.size.y,
        bodyA.rot.c3.xyz_*bodyA.size.z,
        (bodyA.pos):augmented(1)
      )
      local lmatA = matrices.mat4(
        bodyA.lrot.c1.xyz_*bodyA.size.x,
        bodyA.lrot.c2.xyz_*bodyA.size.y,
        bodyA.lrot.c3.xyz_*bodyA.size.z,
        (bodyA.pos-bodyA.vel*delta):augmented(1)
      )
      
      local collisions = {}
      
      for iB, bodyB in pairs(bodies) do
        if iA ~= iB then
          local matB = matrices.mat4(
            bodyB.rot.c1.xyz_*bodyB.size.x,
            bodyB.rot.c2.xyz_*bodyB.size.y,
            bodyB.rot.c3.xyz_*bodyB.size.z,
            (bodyB.pos):augmented(1)
          )
          local lmatB = matrices.mat4(
            bodyB.lrot.c1.xyz_*bodyB.size.x,
            bodyB.lrot.c2.xyz_*bodyB.size.y,
            bodyB.lrot.c3.xyz_*bodyB.size.z,
            (bodyB.pos-bodyB.vel*delta):augmented(1)
          )
          local invMatB = matB:inverted()
          for z = -0.5, 0.5, 0.5 do
            for y = -0.5, 0.5, 0.5 do
              for x = -0.5, 0.5, 0.5 do
                if x ~= 0 and y ~= 0 and z ~= 0 then   
                  local offset = vec(x,y,z)
                  
                  --particles["end_rod"]:pos(matA:apply(offset)):spawn()
                  local Apos = invMatB:apply(matA:apply(offset))
                  local Apos2 = invMatB:apply(lmatA:apply(offset))
                  local Avel = Apos2 - Apos
                  
                  local bodyBpos = invMatB:apply(matB:apply(offset))
                  local bodyBpos2 = invMatB:apply(lmatB:apply(offset))
                  local bodyBvel = bodyBpos2 - bodyBpos
                  
                  if Apos.x >= -0.5 and Apos.y >= -0.5 and Apos.z >= -0.5
                  and Apos.x < 0.5 and Apos.y < 0.5 and Apos.z < 0.5 then
                    local aabb,hitPos,side = raycast:aabb(invMatB:apply(matA.c4.xyz),Apos,{{vec(-0.5,-0.5,-0.5),vec(0.5,0.5,0.5)}})
                    if hitPos then
                      
                      local hitDir = matB:applyDir(side2dir[side])
                      
                      
                      bodyA.pos = bodyA.pos + hitDir * flatten(Apos-hitPos,hitDir):length() + hitDir * MARGIN
                      
                      bodyB.pos = bodyB.pos - hitDir * flatten(Apos-hitPos,hitDir):length() - hitDir * MARGIN
  
                      local massRatio = bodyA.mass / (bodyA.mass + bodyB.mass)
                      
                      local avel = bodyA.vel - bodyB.vel
                      local bvel = -avel
                      
                      -- flatten velocity
                      local favel = flatten(avel,hitDir)
                      local fbvel = flatten(bvel,hitDir)
                      
                      -- flatten impulse
                      local davel = avel - favel
                      local dbvel = bvel - fbvel
                      
                      local friction = 0.1
                      local restitution = 0
                      
                      bodyA:applyImpulseForce(Apos,fbvel * friction)
                      bodyB:applyImpulseForce(Apos,favel * friction)
                      
                      -- impulse
                      bodyA:applyImpulseForce(Apos,dbvel * (1-massRatio))
                      bodyB:applyImpulseForce(Apos,davel * massRatio)
                      
                      bodyA:applyImpulseForce(Apos,dbvel * restitution)
                      bodyB:applyImpulseForce(Apos,davel * restitution)
                      
                      particles["end_rod"]:pos(matA:apply(offset)):color(endesga.red):velocity(hitDir):gravity(0):spawn()
                    end
                  end
                end
                end
            end
          end
        end
      end
    end
    end
end)






local body = RigidBody.new({
  density = 1,
  size = vec(2,2,2),
  pos = vec(-2,5,0),
  vel = vec(1,0,0),
  block="smooth_stone"
})

local body2 = RigidBody.new({
  density = 1,
  size = vec(1,1,1),
  pos = vec(1,5,0),
  vel = vec(-1,0,0),
  block="smooth_stone"
})