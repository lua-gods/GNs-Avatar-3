
---Utility function for recursively cloning a model.
---@param model ModelPart
local function recursiveCopy(model)
  local clone = model:copy(model:getName())
  for _, child in pairs(clone:getChildren()) do
    clone:removeChild(child)
    clone:addChild(recursiveCopy(child))
  end
  return clone
end

local base = models.playerHead
:setParentType("SKULL")
:setPrimaryRenderType("CUTOUT_CULL")
local modelPlushie = base.plushie
local modelHead = base.head:scale(1.15,1.15,1.15)
local modelItem = base.item:scale(1.2,1.2,1.2)
--local modelStatue = recursiveCopy(models.player):setParentType("Skull"):setPos(0,-19.5,0):scale(0.8)
--models:addChild(modelStatue)
--for key, child in pairs(modelStatue:getChildren()) do
--  child:setParentType("NONE")
--end



local avatarVars = {}

local function colorGrade(clr,hue,saturation,value)
  local hsv = vectors.rgbToHSV(clr)
  return vectors.hsvToRGB(math.lerp(hsv.x,0.5,clr.g*hue),math.clamp(saturation + hsv.y,0,1),math.clamp(value + hsv.z,0,1))
end


events.SKULL_RENDER:register(function (delta, block, item, entity, ctx)
  local situation = 0
  if ctx == "BLOCK" then situation = 1 end
  if ctx == "HEAD" then situation = 2 end
  --if entity and entity:getType() == "minecraft:armor_stand" then situation = 3 end
  
  if situation == 2 then
    local vars = avatarVars[entity:getUUID()] or {}
    local color = vars.color or "#5ac54f"
    local height = 7 --vars.hat_height and tonumber(vars.hat_height) or 7
    if type(color) == "string" then
      color = vectors.hexToRGB(color)
    end
    modelHead.cylinder:setScale(1,height or 10,1)
    modelHead.ribbon.shade4:setColor(color)
    modelHead.ribbon.shade3:setColor(colorGrade(color,0,0.05,-0.1))
    modelHead.ribbon.shade2:setColor(colorGrade(color,0,0.25,-0.25))
    modelHead.ribbon.shade1:setColor(colorGrade(color,0,0.5,-0.4))
  --elseif situation == 3 then
  --  local pose = entity:getNbt().Pose
  --  for key, value in pairs(pose) do
  --    pose[key] = vec(value[1] or 0,value[2] or 0,value[3] or 0)
  --  end
  --  pose.Head = pose.Head or vec(0,0,0)
  --  pose.Body = pose.Body or vec(0,0,0)
  --  pose.LeftArm = pose.LeftArm or vec(-10,0,-10)
  --  pose.RightArm = pose.RightArm or vec(-10,0,10)
  --  pose.LeftLeg = pose.LeftLeg or vec(0,0,0)
  --  pose.RightLeg = pose.RightLeg or vec(0,0,0)
  --  
  --  local invHead = matrices.mat4()
  --  :translate(0,-24)
  --  :rotateZ(-pose.Head.z)
  --  :rotateY(pose.Head.y)
  --  :rotateX(pose.Head.x)
  --  
  --  local body = matrices.mat4()
  --  :rotateX(-pose.Body.x)
  --  :rotateY(-pose.Body.y)
  --  :rotateZ(pose.Body.z)
  --  :translate(0,24)
  --  modelStatue.Body:setMatrix(body * invHead)
  --  
  --  local leftArm = matrices.mat4()
  --  :rotateX(-pose.LeftArm.x)
  --  :rotateY(-pose.LeftArm.y)
  --  :rotateZ(pose.LeftArm.z)
  --  :translate(-4,24)
  --  modelStatue.LeftArm:setMatrix(invHead)
  --  
  end
  modelHead:setVisible(situation == 2)
  modelPlushie:setVisible(situation == 1)
  modelItem:setVisible(situation == 0)
  --modelStatue:setVisible(situation == 3)
  
end)

events.WORLD_RENDER:register(function (delta)
  avatarVars = world.avatarVars()
end)