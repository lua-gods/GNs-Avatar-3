local SkullSystem = require("scripts.skullSystem")
local skullType = SkullSystem.registerType("waffle","minecraft:bamboo_pressure_plate")

local model = models.waffle
:setVisible(false)
:setPrimaryRenderType("BLURRY")


skullType.init = function (skull)

	local plushie = skull:attachToHead(model)
   skull.data.plushie = plushie
   skull.data.music = sounds:playSound("waffle",skull.pos+vec(0.5,0.5,0.5),1,1,true) 
end

local time = 0
skullType.firstRender = function (skull, deltaTick, deltaFrame)
	time = client:getSystemTime() / 400
end

local timer = 0.4
skullType.render = function (skull, deltaTick, deltaFrame)
   timer = timer + deltaFrame
   skull.data.plushie:setRot(50,time*-10,0)
end

skullType.exit = function (skull)
   skull.data.music:stop()
end