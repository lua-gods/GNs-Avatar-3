local model = models.accessories.sword.model
local model_glow = models.accessories.sword.model.anchor.handle.glow

local SCALE = 0.4

local model_parent = model:getParent()
model_parent:setParentType("Body"):setPivot(0,24,0)
model_glow:setPrimaryRenderType("EMISSIVE_SOLID")
model:setScale(SCALE,SCALE,SCALE)
animations["accessories.sword.model"].rest:play()
