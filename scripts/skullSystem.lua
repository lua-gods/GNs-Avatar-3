
local UP = vec(0,1,0)
local FACE_2_DIR = {
	south = vec(0,0,1),
	west = vec(-1,0,0),
	north = vec(0,0,-1),
	east = vec(1,0,0)
}

local FACE_2_ROT = { -- NOTE: flipped for convinience, not ground truth
	south = 180,
	west = 90,
	north = 0,
	east = 270
}


local worldPart = models:newPart("GN.skullSystem","Skull")
local headHider = models:newPart("GN.skullSystem","Skull"):newBlock("a"):block("dirt"):scale(0,0,0)


local skullTypes = {}
local supportBlockHashmap = {}
local skullTypeInstances = {}

local skulls = {}

---An instance of a skull
---@class GN.SkullSystem.Instance
---@field id string
---@field pos Vector3
---@field dir Vector3
---@field rot number
---@field offset Vector3
---@field blockModel ModelPart
---@field headModel ModelPart
---@field data table
local Skull = {}
Skull.__index = Skull

---clones the model and parents that to the headModel.  
---rotated and offsetted the way the vanilla skull is.  
---***
---the returned model is the cloned modelPart
---@param model ModelPart
---@return ModelPart
function Skull:attachToHead(model)
   local newModel = model:copy(model:getName()):setVisible(true)
   self.headModel:addChild(newModel)
   return newModel
end


---clones the model and parents that to the blockModel.  
---which is a model thats positioned at the corner of the head's block position  
---***
---the returned model is the cloned modelPart
---@param model ModelPart
---@return ModelPart
function Skull:attachToBlock(model)
   local newModel = model:copy(model:getName()):setVisible(true)
   self.headModel:addChild(newModel)
   return newModel
end



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
local firstHead = false
local lastSystemTime = client:getSystemTime()
events.WORLD_RENDER:register(function (deltaTick)
   local systemTime = client:getSystemTime()
   local deltaFrame = (systemTime - lastSystemTime) / 1000
   lastSystemTime = systemTime
   
	if not canStart then return end
	firstHead = true
	
	-- remove skulls that dint show up in skull render
	for id, instance in pairs(toRemove) do
      if not world.getBlockState(instance.pos).id:find("head$") then
         instance.blockModel:remove()
         if skullTypes[instance.type].exit then
            skullTypes[instance.type].exit(instance)
            skullTypeInstances[skullTypes[instance.type]][instance.id] = nil
         end
         skulls[id] = nil
      end
	end
	-- put every skull back into the remove queue
	toRemove = {}
	for key, value in pairs(skulls) do
		toRemove[key] = value
	end
	
	
	for type, instances in pairs(skullTypeInstances) do
		local first = true
		for _, instance in pairs(instances) do
			if first then
				first = false
				if type.firstRender then type.firstRender(instance,deltaTick,deltaFrame) end
			end
			if type.render then type.render(instance,deltaTick,deltaFrame) end
		end
	end
	
end)

events.WORLD_TICK:register(function ()
	if not canStart then return end
	for type, instances in pairs(skullTypeInstances) do
		local first = true
		for _, instance in pairs(instances) do
			if first then
				first = false
				if type.firstTick then type.firstTick(instance) end
			end
			if type.tick then type.tick(instance) end
		end
	end
end)

events.SKULL_RENDER:register(function (delta, block, item, entity, ctx)
	if not canStart then return end
	local isBlock = ctx:find("^B") and true
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
			toRemove[id] = nil -- remove the skull from the remove queue because it updated
		else
			if block.id == "minecraft:player_wall_head" then
            local facing = block.properties.facing
				dir = FACE_2_DIR[facing]
				rot = FACE_2_ROT[facing]
				offset = vec(8 - dir.x * 4,4,8 - dir.z * 4)
			else
				dir = UP
				rot = tonumber(block.properties.rotation) * -22.5
				offset = vec(8,0,8)
			end
			
			blockModel = worldPart:newPart(id):pos(pos * 16) ---@type ModelPart
			headModel = blockModel:newPart("offset"):pos(offset):rot(0,rot,0) ---@type ModelPart
			
			local supportBlock = world.getBlockState(pos - dir)
			local skullType = supportBlockHashmap[supportBlock.id] or "default"
			
			skull = {
				dir = dir,
				rot = rot,
				id = id,
				type = skullType,
				support = supportBlock,
				pos = pos,
				offset = offset,
				blockModel = blockModel,
				headModel = headModel,
				data = {}
			}
         setmetatable(skull,Skull)
			skulls[id] = skull
			local skullTypeData = skullTypes[skullType]
			skullTypeInstances[skullTypeData] = skullTypeInstances[skullTypeData] or {}
			skullTypeInstances[skullTypeData][id] = skull
			
			skullTypes[skullType].init(skull)
		end
		
		if firstHead then
			firstHead = false
			local rad = math.rad(rot)
			local fpos = pos * 16 + offset
			worldPart:setPos(vec(
				(math.sin(rad) * fpos.z - math.cos(rad) * fpos.x),
				-fpos.y,
				(-math.cos(rad) * fpos.z - math.sin(rad) * fpos.x)
			)):setRot(0,-rot,0)
			worldPart:setVisible(true)
		else
			worldPart:setVisible(false)
			headHider:setVisible(true)
		end
	else
		worldPart:setVisible(false)
	end
end)


---@class GN.SkullSystem
local SkullSystem = {}
SkullSystem.__index = SkullSystem


---A registered type of skull
---@class GN.SkullSystem.Type
---@field id string
---@field init fun(skull : GN.SkullSystem.Instance) # triggers when the skull is created
---@field exit fun(skull : GN.SkullSystem.Instance) # triggers when the skull is removed
---@field tick fun(skull : GN.SkullSystem.Instance) # triggers on every in game tick
---@field firstTick fun(skull : GN.SkullSystem.Instance) # tick but only on the first skull that ticks
---@field render fun(skull : GN.SkullSystem.Instance, deltaTick : number, deltaFrame : number) # triggers on every frame
---@field firstRender fun(skull : GN.SkullSystem.Instance, deltaTick : number, deltaFrame : number) # render but only on the first skull that renders


---@param id string
---@param supportBlock Minecraft.blockID?
---@return GN.SkullSystem.Type
function SkullSystem.registerType(id,supportBlock)
	local type = {id = id}
	skullTypes[id] = type
	if supportBlock then
		supportBlockHashmap[supportBlock] = id
	end
	return type
end

return SkullSystem