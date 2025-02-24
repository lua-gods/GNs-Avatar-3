local SkullSystem = require("scripts.skullSystem")
local skullType = SkullSystem.registerType("default")


local modelPlushie = models.playerHead.plushie
:setPrimaryRenderType("CUTOUT_CULL")
:setVisible(false)

skullType.init = function (skull)
   
	local pos = skull.pos + skull.offset / 16
	local block, hitpos = raycast:block(pos,pos+vec(0,-1,0),"OUTLINE","NONE")
	local height = (hitpos.y - pos.y) * 16

	local plushie = skull:attachToHead(modelPlushie):setPos(0,height,0)
	if block.id:find("water") then skull.data.isWater = true end
	skull.data.plushie = plushie
end

local time = 0
skullType.firstRender = function (skull, deltaTick, deltaFrame)
	time = client:getSystemTime() / 5000
end

skullType.render = function (skull, deltaTick, deltaFrame)
	if skull.data.isWater then
		skull.data.plushie
		:setPos(0,utils.fractralSine(time, 69,5,0.5,1.4) * 8-4,0)
		:setRot(
			utils.fractralSine(time, 101,5,0.5,1.1) * 45,
			utils.fractralSine(time/10, 102,5,0.5,1.1) * 90,
			utils.fractralSine(time, 104,5,0.5,1.1) * 45
		)
	end
end