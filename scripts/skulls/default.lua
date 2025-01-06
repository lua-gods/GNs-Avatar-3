local SkullSystem = require("scripts.skullSystem")
local skullType = SkullSystem.registerType("default")


local modelPlushie = models.playerHead.plushie
:setPrimaryRenderType("CUTOUT_CULL")
:remove()

skullType.init = function (skull)
   skull.headModel:addChild(modelPlushie:copy("plushie"))
end