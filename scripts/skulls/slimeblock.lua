local SkullSystem = require("scripts.skullSystem")
local skullType = SkullSystem.registerType("slimeblock","minecraft:slime_block")

local modelPlushie = models.playerHead.plushie

skullType.init = function (skull)
   skull.data.plushie = skull:attachToHead(modelPlushie)
end

local time = 0
skullType.firstRender = function ()
	time = client:getSystemTime() * 0.003
end

skullType.render = function (skull, deltaTick, deltaFrame)
   local stretch = math.sin(time*-2) * 0.2 + 1
   skull.data.plushie
   :pos(0,math.abs(math.sin(time))*16,0)
   :scale(1/stretch,stretch,1/stretch)
end