local SkullSystem = require("scripts.skullSystem")
local skullType = SkullSystem.registerType("jukebox","minecraft:jukebox")

local modelPlushie = models.playerHead.plushie

skullType.init = function (skull)
   skull.data.plushie = skull:attachToHead(modelPlushie)
end

local time = 0
skullType.firstRender = function ()
	time = client:getSystemTime() * 0.003
end

skullType.render = function (skull, deltaTick, deltaFrame)
   local stretch = math.abs(time % 2 - 1) * 0.2 + 0.9
   skull.data.plushie
   :scale(1/stretch,stretch,1/stretch)
	:rot(0,-math.cos(time*math.pi / 2)*15,math.sin(time*math.pi / 2)*5)
end