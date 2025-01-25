local SkullSystem = require("scripts.skullSystem")
local skullType = SkullSystem.registerType("sunflower","minecraft:flower_pot")

local atlas= textures["textures.sunflower"]
local FRAMES = 55
local invFRAMES = 1/FRAMES



skullType.init = function (skull)
	local origin = skull.headModel:newPart("origin"):pos(0,0,0)
	---@type SpriteTask
	local board = origin:newSprite("board"):setTexture(atlas,atlas:getDimensions().yy:unpack()):scale(0.2):pos(10,16):setRenderType("BLURRY")
   skull.data.board = board
   skull.data.origin = origin:pos(0,-10,0)
	skull.data.music = sounds.Sunflower:play():loop(true):attenuation(1)
	
	local verts = board:getVertices()
	verts[1]:setUV(0,1)
	verts[2]:setUV(invFRAMES,1)
	verts[3]:setUV(invFRAMES,0)
end

local time = 0
local closest = math.huge
skullType.firstRender = function (skull, deltaTick, deltaFrame)
	time = client:getSystemTime() / 38
	
end

skullType.render = function (skull, deltaTick, deltaFrame)
	local board = skull.data.board
	
	local x = (math.floor(time) % FRAMES) * invFRAMES
	local verts = board:getVertices()
	verts[1]:setUV(x-invFRAMES,1)
	verts[2]:setUV(x,1)
	verts[3]:setUV(x,0)
	verts[4]:setUV(x-invFRAMES,0)
	local diff = client:getCameraPos()-(skull.pos+vec(0.5,0.5,0.5))
	local dist = diff:length()
	
	skull.data.music:pos(client:getCameraPos() + client:getCameraDir())
	:volume(math.clamp(math.map(dist,3,1,0,2),0,1))
	skull.data.origin:rot(0,math.deg(math.atan2(diff.x,diff.z)))
end

skullType.exit = function (skull)
	skull.data.music:stop()
end