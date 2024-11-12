local model = models.accessories.sword.model
local model_blade = models.accessories.sword.model.anchor.handle
local model_control = models.accessories.sword.model.control
local model_glow = models.accessories.sword.model.anchor.handle.glow

local trailLib = require("libraries.trail")

local colors = {
  "#d3fc7e",
  "#99e65f",
  "#5ac54f",
  "#33984b",
}

local trails = {}
local trail_datas = {}

-- 8 19

math.randomseed(8)
for i = 1, 1, 1 do
  local j = 1.0/i
  trails[i] = trailLib:newTwoLeadTrail(textures["textures.glow"]):setDuration(2 + (math.random() * 10)):setDivergeness(math.random() * .5):setRenderType("EMISSIVE_SOLID")
  trail_datas[i] = {math.random(),1*j,math.random(),math.random()}
end

local model_parent = model:getParent()
model_parent:setParentType("Body"):setPivot(0,24,0)
model_glow:setPrimaryRenderType("EMISSIVE_SOLID")
animations["accessories.sword.model"].rest:play()

local left_handed = false
local active = false

events.ENTITY_INIT:register(function ()
  left_handed = player:isLeftHanded()
end)
local item

events.TICK:register(function ()
  if player:getSwingTime() == 1 then -- player swung
    if active then
      sounds.oof:pos(player:getPos()):play():pitch(0.5)
    end
    animations["accessories.sword.model"].swing1:stop()
    animations["accessories.sword.model"].rest:stop()
    animations["accessories.sword.model"].swing1:play()
  end
  
  local held = player:getHeldItem().id
  if held ~= item then
    item = held
    active = held:find("sword") and true or false
    model:setVisible(active)
    if left_handed then
      vanilla_model.LEFT_ITEM:setVisible(not active)
    else
      vanilla_model.RIGHT_ITEM:setVisible(not active)
    end
  end
end)

events.RENDER:register(function (delta, ctx, matrix)
  if ctx == "RENDER" then
    local scale = model_control:getAnimPos().x
    local mat = model_blade:partToWorldMatrix()
    for key, trail in pairs(trails) do
      local trail_data = trail_datas[key]
      local y = trail_data[2]
      trail:setLeads(
        mat:apply(0,trail_data[1] * 16,y),
        mat:apply(0,trail_data[2] * 32 ,y),
        scale)
    end
  end
end)