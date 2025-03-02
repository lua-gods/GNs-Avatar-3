
local BASE = models.playerHead:setParentType("SKULL")
local BLOCK = models.playerHead.plushie:setVisible(false)
local HEAD = models.playerHead.head:setVisible(false)
local ITEM = models.playerHead.item:setVisible(false)

local STATES = {
	BLOCK,
	HEAD,
	ITEM,
	BASE:newPart("placeholder","NONE")
}

local colors = require "lib.palettes.endesga64"

local function shade(clr,w)
	return math.lerp(colors.darkestBlueGray,clr,w)
end

local lastState = 4
events.SKULL_RENDER:register(function (delta, block, item, entity, ctx)
	local state = ctx == "BLOCK" and 1 or ctx == "HEAD" and 2 or 3
	if lastState ~= state then
		STATES[lastState]:setVisible(false)
		STATES[state]:setVisible(true)
		lastState = state
	end
	if state == 2 then
		local vars = entity:getVariable()
		local height = vars.hatHeight or 8
		local color = vars.color and utils.parseColor(vars.color).xyz or colors.green
		HEAD.cylinder:setScale(1,height,1)
		
		for i = 1, 4, 1 do
			HEAD.ribbon["shade"..i]:setColor(shade(color,i/4))
		end
	end
end)