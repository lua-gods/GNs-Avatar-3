local modelWorld = models:newPart("modelWorld","WORLD")

local model = modelWorld:newPart("Body")
model:newBlock("block"):block("minecraft:grass_block"):pos(-8,-8,-8)

local Line = require"libraries.line"

local side2dir = {
  north = vec(0,0,-1),
  east = vec(1,0,0),
  south = vec(0,0,1),
  west = vec(-1,0,0),
  up = vec(0,1,0),
  down = vec(0,-1,0)
}

---Calculates the inertia tensor
---@param size Vector3
---@return Vector3
local function inertiaCuboidDensity(size)
  local d = size*size
  return (size.x * size.y * size.z) * vec(d.y+d.z, d.x+d.z, d.x+d.y) / 12
end


local size = vec(2,2,2)

local body = {
  origin = vec(0,0,0), -- center of mass
  
  vel = vec(0,0,0), -- linear velocity
  pos = vec(0,4,0),
  
  mass = 1,
  volume = size.x * size.y * size.z,
  size = size,
  
  rot = matrices.mat3():rotateX(45), -- orientation
  rvel = vec(0,0,0), -- angular velocity, 
  ---xyz represents the axis to rotate to, length represents speed.
  invInertia = vec(1,1,1) / inertiaCuboidDensity(size),
}

local endesga = require"palettes.endesga64"

local lines = {
  x = Line.new():setColor(endesga.red),
  y = Line.new():setColor(endesga.green),
  z = Line.new():setColor(endesga.blue),
  l = Line.new():setColor(endesga.lightBlue),
  o = Line.new():setColor(endesga.pinkRed),
  v = Line.new():setColor(endesga.orange),
  hit = Line.new():setColor(endesga.violet),
}
for key, l in pairs(lines) do l:setWidth(0.05) end


---@param pos Vector3
---@param vel Vector3
local function applyImpulseForce(pos,vel)
  local offset = pos - body.pos
  body.vel = body.vel + vel
  local torque = offset:cross(vel)
  body.rvel = body.rvel + torque
end



local lastSystemTime = client:getSystemTime()
events.WORLD_RENDER:register(function (dt)
  local systemTime = client:getSystemTime()
  local delta = (systemTime - lastSystemTime) / 1000
  lastSystemTime = systemTime
  
  -- simulation
  body.pos = body.pos + body.vel * delta
  
  local invInertia = matrices.mat3(
    vec(body.invInertia.x,0,0),
    vec(0,body.invInertia.y,0),
    vec(0,0,body.invInertia.z)
  )
  
  local omega = (body.rot * invInertia * body.rot:transposed()) * (body.rvel:length() ~= 0 and body.rvel or vec(0,0.000001,0))
  local speed = math.deg(omega:length()) * delta
  
  body.rot.c1 = vectors.rotateAroundAxis(speed,body.rot.c1,omega)
  body.rot.c2 = vectors.rotateAroundAxis(speed,body.rot.c2,omega)
  body.rot.c3 = vectors.rotateAroundAxis(speed,body.rot.c3,omega)
  
  -- damp
  --body.rvel = body.rvel * 0.95
  --body.vel = body.vel * 0.95
  body.vel = body.vel + vec(0,-1,0)
  
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
    {{size * -0.5,size * 0.5}})
    local hitDir = mat:applyDir(side2dir[side])
    if hitPos then
      hitPos = mat:apply(hitPos)
      lines.hit:setAB(hitPos,hitPos+hitDir)
      if player:getSwingTime() == 1 then
        applyImpulseForce(hitPos,-hitDir*5)
      end
    else
      lines.hit:setAB(vec(0,0,0),vec(0,0,0))
    end
  end
  
  local mat = matrices.mat4(
    body.rot.c1.xyz_:normalized(),
    body.rot.c2.xyz_:normalized(),
    body.rot.c3.xyz_:normalized(),
    (body.pos):augmented(1)
  )
  local resolved = false
  for z = -0.5, 0.5, 1 do
    for y = -0.5, 0.5, 1 do
      for x = -0.5, 0.5, 1 do
        if not resolved then
          local lpos = vec(x*size.x,y*size.y,z*size.z)
          local ppos = mat:apply(lpos)
          if ppos.y < 0 then
            local pvel = (vectors.rotateAroundAxis(speed,mat:applyDir(lpos),omega)) - mat:applyDir(lpos) + body.vel * delta
            particles["end_rod"]:velocity(pvel*10):pos(ppos):spawn()
            applyImpulseForce(ppos,-pvel:mul(1,0,1) / delta)
            applyImpulseForce(ppos,vec(0,-body.vel.y,0))
            body.pos.y = body.pos.y - ppos.y + 0.01
            body.vel:mul(1,0,1)
            resolved = true
          end
        end
      end
    end
  end
  
  -- rendering
  local rMat = matrices.mat4(
    body.rot.c1.xyz_*body.size.x,
    body.rot.c2.xyz_*body.size.y,
    body.rot.c3.xyz_*body.size.z,
    (body.pos * 16):augmented(1)
  )
  model:setMatrix(rMat)
  
  -- debug
  local rvelDir = body.rvel:length() ~= 0 and body.rvel:normalized() or vec(0,1,0)
  local omegaDir = omega:normalized()
  lines.x:setAB(body.pos,body.pos+body.rot.c1 * 1.5)
  lines.y:setAB(body.pos,body.pos+body.rot.c2 * 1.5)
  lines.z:setAB(body.pos,body.pos+body.rot.c3 * 1.5)
  lines.l:setAB(body.pos-rvelDir*2,body.pos+rvelDir*2)
  lines.o:setAB(body.pos-omegaDir*2,body.pos+omegaDir*2)
  lines.v:setAB(body.pos-body.vel*2,body.pos+body.vel*2)
end)

