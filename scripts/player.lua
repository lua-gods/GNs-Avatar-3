vanilla_model.PLAYER:setVisible(false)
vanilla_model.ELYTRA:setVisible(false)
vanilla_model.ARMOR:setVisible(false)
vanilla_model.HELMET_ITEM:setVisible(true)
vanilla_model.CAPE:setVisible(true)
renderer:setShadowRadius(0.4)
models.player:setPrimaryRenderType("CUTOUT") -- enables more shader compatibility

local endesga = require"lib.palettes.endesga64"


events.ENTITY_INIT:register(function ()
	local nbt = player:getNbt()
	local attributes = nbt.attributes or nbt.Attributes
	for k,att in pairs(attributes) do
		if att.id == "minecraft:scale" then
			local inv = 1/att.base
			models.player.Torso.Head:scale(inv,inv,inv)
			break
		end
	end
end)


avatar:store("color","#5ac54f")
avatar:store("hair_color","#5ac54f")
avatar:store("horn_color","#2a2f4e")

avatar:store("AllowAI",true)