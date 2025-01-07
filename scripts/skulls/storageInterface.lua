local SkullSystem = require("scripts.skullSystem")
local skullType = SkullSystem.registerType("Storage Interface","minecraft:crafting_table")


skullType.init = function (skull)
	-- Generate search offsets
	local rad = math.rad(skull.rot)
	local offsets = {
		vec(0,1,0),
		vec(0,-1,0),
		vec(math.cos(rad) ,0, math.sin(rad)),
		vec(-math.cos(rad) ,0, -math.sin(rad)),
	}
	
	-- Flood fill
	local newNodes = {}
	local nodes = {}
	
	local function toID(pos) return ("%s,%s,%s"):format(pos.x, pos.y, pos.z)end
	
	local function nodeAt(pos)
		local id = toID(pos)
		newNodes[id] = pos
		nodes[id] = pos
	end
	
	
	-- Start search at the head
	nodeAt(skull.pos)
	for step = 1, 10, 1 do
		local searchNodes = newNodes
		newNodes = {}
		for _, newNode in pairs(searchNodes) do
			for _, offset in pairs(offsets) do
				local checkPos = newNode + offset
				if not nodes[toID(checkPos)] and world.getBlockState(checkPos).id:find("wall_sign$") then
					nodeAt(checkPos)
					particles["end_rod"]:pos(checkPos + vec(0.5,0.5,0.5)):spawn()
				end
			end
		end
	end
end

skullType.render = function (skull, deltaTick, deltaFrame)
end