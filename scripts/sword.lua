if avatar:getPermissionLevel() ~= "MAX" then
	models.sword:setVisible(false)
	return
end

models.sword:setPrimaryRenderType("CUTOUT_CULL")
models.sword.Roll.Pole.Handle.bone.glow:setPrimaryRenderType("EMISSIVE_SOLID")

local is_holding_sword = false
local was_holding_sword

local MAX_ROLL = 45

local GNanim = require("lib.GNanimClassic")
local trail = require("lib.GNtrailLib")

local state = GNanim.new()

local lpos = vectors.vec3()
local pos = vectors.vec3()
local lrot = 0
local rot = 0

local SCALE = 0.5
local SPEED = 1 / SCALE


local swing_count = 0
local roll2 = 0
local roll1 = 0
local weary = 0.9
local sword = models.sword:scale(SCALE)
sword:setParentType("WORLD")
local sword_trail = trail:newTwoLeadTrail(textures["textures.trail"])
sword_trail:setDivergeness(0)
sword_trail:setRenderType("EMISSIVE_SOLID")

local function setScale(scale)
	SCALE = scale
	SPEED = 1 / scale
	for key, value in pairs(animations.sword) do value:speed(SPEED) end
	state:setBlendTime(0.1 / SPEED)
	models.sword:scale(SCALE)
	sword_trail:setDuration(10/SPEED)
end

events.ENTITY_INIT:register(function()
	pos = player:getPos()
	lpos = pos:copy()
	rot = player:getRot().y
	lrot = rot
end)

events.TICK:register(function()
	lrot = rot
	lpos = pos
	pos = math.lerp(pos, player:getPos(), vectors.vec3(0.8, 0.3, 0.8))
	rot = math.lerp(rot, player:getBodyYaw(), 0.3)
	if was_holding_sword ~= is_holding_sword then
		state:setAnimation(is_holding_sword and animations.sword.idle2prepare or animations.sword.prepare2idle)
		was_holding_sword = is_holding_sword
		if not is_holding_sword then swing_count = 0 end
	end
	if is_holding_sword then
		if player:getSwingTime() == 1 then
			sounds:playSound("swing", player:getPos():add(0, 1, 0), 0.3, (1 + (math.random() - 0.5) * 0.2 )* SPEED)
			if swing_count % 2 == 1 then
				roll1 = math.random(-MAX_ROLL, MAX_ROLL)
				state:setAnimation(animations.sword.swing2swing2)
			else
				roll2 = math.random(-MAX_ROLL, MAX_ROLL)
				state:setAnimation(animations.sword.swing2swing)
			end
			swing_count = swing_count + 1
		end
	end
end)
local lastEyeHeight = 0
sword.midRender = (function(dt)
	if player:isLoaded() then
		local eyeHeight = player:getEyeHeight()
		if lastEyeHeight ~= eyeHeight then
			lastEyeHeight = eyeHeight
			setScale(eyeHeight/1.62)
		end
		local meta = models.sword.metadata:getAnimPos()
		local mat = models.sword.Roll.Pole.Handle:partToWorldMatrix()
		sword_trail:setLeads(mat:apply(0, 0, 1), mat:apply(0, 0, -28), meta.x * 2)
		local r = player:getBodyYaw(dt)
		local sneak = player:isSneaking() and player:isOnGround()
		local dir = vectors.rotateAroundAxis(-r, vectors.vec3(0, .25, 1), vectors.vec3(0, 1, 0))
		sword:pos((math.lerp(player:getPos(dt), math.lerp(lpos, pos, dt), weary) + vec(0,player:getEyeHeight()*0.5,0)) * 16 + (sneak and dir * -10 or vectors.vec3(0, 0, 0)))
		sword:rot(sneak and -30 or 0, 180 - math.lerp(r, math.lerp(lrot, rot, dt), weary), 0)
		sword.Roll:setRot(0, 0, math.lerp(roll1, roll2, meta.x))
		is_holding_sword = (player:getHeldItem().id:find("sword") and true or false)
	end
end)

events.ITEM_RENDER:register(function() if is_holding_sword then return sword.Item end end)

events.RENDER:register(function(delta, context)
	if context == "FIRST_PERSON" then
		if weary == 0 then
			sword:setVisible(false)
		else
			sword:setOpacity(weary):setVisible(true)
		end
	else
		sword:setVisible(context == "RENDER"):setOpacity(1)
	end
	vanilla_model.RIGHT_ARM:setOffsetRot(is_holding_sword and -15 or 0, 0, 0)
	local meta = models.sword.metadata:getAnimPos()
	local systime = client:getSystemTime() / 10000
	weary = meta.y
	models.sword.Roll.Pole.Handle:rot(
		utils.fractralSine(systime, 135351, 10, 0.5, 1.4) * 90 * weary,
		utils.fractralSine(systime, 253631, 10, 0.5, 1.4) * 90 * weary,
		utils.fractralSine(systime, 34124, 10, 0.5, 1.4) * 90 * weary
	):pos(
		utils.fractralSine(systime, 4214, 10, 0.5, 1.2) * 16 * weary,
		utils.fractralSine(systime, 53631, 10, 0.5, 1.2) * 16 * weary,
		utils.fractralSine(systime, 4124, 10, 0.5, 1.2) * 16 * weary)
end)
