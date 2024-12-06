vanilla_model.PLAYER:setVisible(false)
vanilla_model.ELYTRA:setVisible(false)
vanilla_model.ARMOR:setVisible(false)
vanilla_model.HELMET_ITEM:setVisible(true)
vanilla_model.CAPE:setVisible(true)
renderer:setShadowRadius(0.4)
models.player:setPrimaryRenderType("CUTOUT") -- enables more shader compatibility

local endesga = require"lib.palettes.endesga64"

avatar:store("color",endesga.red)
avatar:store("hair_color",endesga.red)
avatar:store("horn_color","#2a2f4e")

--avatar:store("color","#5ac54f")
--avatar:store("hair_color","#5ac54f")
--avatar:store("horn_color","#2a2f4e")

avatar:store("AllowAI",true)