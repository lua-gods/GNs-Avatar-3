
local UP = vec(0,1,0)
local FACE_2_DIR = {
	south = vec(0,0,1),
	west = vec(-1,0,0),
	north = vec(0,0,-1),
	east = vec(1,0,0)
}

local FACE_2_ROT = {
	south = 0,
	west = 90,
	north = 180,
	east = 270
}


local worldPart = models:newPart("GN.skullSystem","Skull")
local headHider = models:newPart("GN.skullSystem","Skull"):newBlock("a"):block("dirt"):scale(0,0,0)


local skullTypes = {}
local supportBlockHashmap = {}
local skullTypeInstances = {}

local skulls = {}


local startupCooldown = 10
local canStart = false
events.WORLD_RENDER:register(function ()
	startupCooldown = startupCooldown - 1
	if startupCooldown <= 0 then
		canStart = true
		events.WORLD_RENDER:remove("GN.SkullSystem.startup_cooldown")
	end
end,"GN.SkullSystem.startup_cooldown")


local toRemove = {}
local headRenderCount = 0
events.WORLD_RENDER:register(function ()
	if not canStart then return end
	headRenderCount = 0
	
	-- remove skulls that dint show up in skull render
	for id, instance in pairs(toRemove) do
		instance.blockModel:remove()
		skulls[id] = nil
	end
	-- put every skull back into the remove queue
	toRemove = {}
	for key, value in pairs(skulls) do
		toRemove[key] = value
	end
	
	
	for type, instances in pairs(skullTypeInstances) do
		for _, instance in pairs(instances) do
			if type.render then type.render(instance) end
		end
	end
	
	
end)

events.WORLD_TICK:register(function ()
	if not canStart then return end
	for type, instances in pairs(skullTypeInstances) do
		for _, instance in pairs(instances) do
			if type.tick then type.tick(instance) end
		end
	end
end)

events.SKULL_RENDER:register(function (delta, block, item, entity, ctx)
	if not canStart then return end
	local isBlock = ctx:find("^B") and true
	worldPart:setVisible(false)
	if isBlock then -- block
		local pos = block:getPos()
		local id = ("%s,%s,%s"):format(pos.x, pos.y, pos.z)
		local skull = skulls[id]
		
		local dir
		local rot = 0
		local offset
		local blockModel
		local headModel
		
		if skull then -- check if the skull is registered
			dir = skull.dir
			rot = skull.rot
			offset = skull.offset
			blockModel = skull.blockModel
			headModel = skull.model
			toRemove[id] = nil -- remove the skull from the remove queue because it updated
		else
			if block.id == "minecraft:player_wall_head" then
				dir = FACE_2_DIR[block.properties.facing]
				rot = FACE_2_ROT[block.properties.facing]
				offset = vec(
				8 + dir.x * 4,
				4,
				8 + dir.z * 4
			)
			else
				dir = UP
				rot = tonumber(block.properties.rotation) * -22.5
				offset = vec(8,0,8)
			end
			
			blockModel = worldPart:newPart(id):pos(pos * 16) ---@type ModelPart
			headModel = blockModel:newPart("offset"):pos(offset):rot(0,rot,0) ---@type ModelPart
			
			local supportBlock = world.getBlockState(pos - dir).id
			local skullType = supportBlockHashmap[supportBlock] or skullTypes.default
			
			skull = {
				dir = dir,
				rot = rot,
				id = id,
				pos = pos,
				offset = offset,
				blockModel = blockModel,
				headModel = headModel,
			}
			skulls[id] = skull
			skullTypeInstances[skullType] = skullTypeInstances[skullType] or {}
			skullTypeInstances[skullType][id] = skull
			
			skullType.init(skull)
		end
		
		headRenderCount = headRenderCount + 1
		if headRenderCount == 1 then -- first render
			local rad = math.rad(rot)
			local fpos = pos * 16 + offset
			worldPart:setPos(vec(
				(math.sin(rad) * fpos.z - math.cos(rad) * fpos.x),
				-fpos.y,
				(-math.cos(rad) * fpos.z - math.sin(rad) * fpos.x)
			)):setRot(0,-rot,0)
			worldPart:setVisible(true)
		else
			headHider:setVisible(true)
		end
	end
end)


---@class GN.SkullSystem
local SkullSystem = {}
SkullSystem.__index = SkullSystem


---A registered type of skull
---@class GN.SkullSystem.Type
---@field id string
---@field init fun(skull : GN.SkullSystem.Instance)
---@field exit fun(skull : GN.SkullSystem.Instance)
---@field tick fun(skull : GN.SkullSystem.Instance)
---@field render fun(skull : GN.SkullSystem.Instance, deltaTick : number, deltaFrame : number)

---An instance of a skull
---@class GN.SkullSystem.Instance
---@field id string
---@field pos Vector3
---@field dir Vector3
---@field rot number
---@field offset Vector3
---@field blockModel ModelPart
---@field headModel ModelPart


---@param id string
---@param supportBlock Minecraft.blockID?
---@return GN.SkullSystem.Type
function SkullSystem.registerType(id,supportBlock)
	local type = {id = id}
	skullTypes[id] = type
	if supportBlock then
		supportBlockHashmap[supportBlock] = skullTypes[id]
	end
	return type
end

return SkullSystem