--[[______  __           _            __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]
local SYNC_WAIT_TIME = 0.5 * 20

local endesga = require "lib.palettes.endesga64"
local Gradient = require("lib.gradient")

config:setName("gn.nameplate")
local plate = {
	name = config:load("name") or ("${badges}" .. avatar:getEntityName()),
	gradient = Gradient.new(config:load("gradient") or {
		[0] = endesga.lightGreen,
		[0.5] = endesga.brightGreen,
		[2] = endesga.lightGreen,
		[3] = endesga.darkGreen
	}),
	hoverText = config:load("hoverText") or ""
}



local cluster = {"^:.+:", "^${.+}", "."}

nameplate.ENTITY:setOutline(true)
nameplate.ENTITY:setBackgroundColor(0, 0, 0, 0)

local function makeNameplate()
	if plate.name == "" then return end

	local chars = {}

	do
		local name = plate.name:gsub("\\n", "\n")
		local i = 1
		while i <= #name do
			for j = 1, #cluster, 1 do
				local start, to = name:find(cluster[j], i)
				if start then
					i = to
					chars[#chars + 1] = name:sub(start, to)
					break
				end
			end
			i = i + 1
		end
	end
	---@type Minecraft.RawJSONText.Component[]
	local baked = {{text = "", hoverEvent = {action = "show_text", contents = plate.hoverText}}}
	for i = 1, math.min(#chars, 63), 1 do
		if chars[i] == "${badges}" then avatar:setColor(plate.gradient:sampleRange((i - 1) / #chars)) end
		baked[#baked + 1] = {
			text = chars[i],
			color = "#" .. vectors.rgbToHex(plate.gradient:sampleRange((i - 1) / #chars))
		}
	end
	nameplate.ALL:setText(toJson(baked))
end

plate.makeNameplate = makeNameplate

if IS_HOST then
	
	local waitingSave = false
	local saveCooldown = 20
	
	function plate.save()
		waitingSave = true
		saveCooldown = 20
	end
	
	events.WORLD_TICK:register(function()
		if waitingSave then
			saveCooldown = saveCooldown - 1
			if saveCooldown < 0 then
				waitingSave = false
				config:setName("gn.nameplate")
				config:save("name", plate.name)
				config:save("gradient", plate.gradient:pack())
				config:save("hoverText", plate.hoverText)
			end
		end
	end)
	
	local function sync() pings.syncNameplate(plate.name, plate.gradient:pack()) end
	local timer = 0
	events.WORLD_TICK:register(function()
		timer = timer - 1
		if timer < 0 then
			sync()
			timer = SYNC_WAIT_TIME
		end
	end)
end

---@param name string
---@param gradient string
function pings.syncNameplate(name, gradient)
	plate.name = name
	plate.gradient = Gradient.new(gradient)
	makeNameplate()
end

return plate
