local SkullSystem = require"scripts.skullSystem"
local skullType = SkullSystem.registerType("Storage Interface","minecraft:crafting_table")

local tween = require"lib.tween"

local TRANSFORMS = {
	{
		title = {
			pos = vec(0,-3,1),
			scale = 0,
		},
		desc = {
			pos = vec(0,-5,1),
			scale = 0,
		},
		icon = {
			pos = vec(0,1,0),
			scale = 0.5
		}
	},
	{
		title = {
			pos = vec(0,-3,1),
			scale = 0.3,
		},
		desc = {
			pos = vec(0,-5,1),
			scale = 0.25,
		},
		icon = {
			pos = vec(0,1,0),
			scale = 0.75
		}
	}
}

local function applyTransforms(title,desc,icon,blend)
	local titleScale = math.lerp(TRANSFORMS[1].title.scale,TRANSFORMS[2].title.scale,blend)
	local descScale = math.lerp(TRANSFORMS[1].desc.scale,TRANSFORMS[2].desc.scale,blend)
	local iconScale = math.lerp(TRANSFORMS[1].icon.scale,TRANSFORMS[2].icon.scale,blend)
	title
	:pos(math.lerp(TRANSFORMS[1].title.pos,TRANSFORMS[2].title.pos,blend))
	:scale(titleScale):setVisible(titleScale > 0.01)
	desc
	:pos(math.lerp(TRANSFORMS[1].desc.pos,TRANSFORMS[2].desc.pos,blend))
	:scale(descScale):setVisible(descScale > 0.01)
	icon
	:pos(math.lerp(TRANSFORMS[1].icon.pos,TRANSFORMS[2].icon.pos,blend))
	:scale(iconScale):setVisible(iconScale > 0.01)
end


---@param pos Vector3
---@param dir Vector3
---@param planeDir Vector3
---@param planePos Vector3
---@return Vector3?
local function ray2PlaneIntersection(pos,dir,planePos,planeDir)
	local dn = dir:normalized()
	local pdn = planeDir:normalized()

	local dot = dn:dot(pdn)
	if math.abs(dot) < 1e-6 then return nil end
	local dtp = pdn:dot(planePos - pos) / dot
	local ip = pos + dn * dtp
	return ip
end

local function toID(pos) return ("%s,%s,%s"):format(pos.x, pos.y, pos.z)end


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

	
	local function nodeAt(pos)
		local id = toID(pos)
		newNodes[id] = pos
		nodes[id] = pos
	end
	
	
	-- Start search at the head
	nodeAt(skull.pos)
	for _ = 1, 10, 1 do
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
	nodes[toID(skull.pos)] = nil
	
	for id, pos in pairs(nodes) do
		local block = world.getBlockState(pos)
		local lines = block:getEntityData().front_text.messages
		local itemLine = lines[1]:sub(2,-2)
		local isItem,item = pcall(world.newItem,itemLine,1)
		local clrok,clr = pcall(utils.parseColor,lines[4]:sub(2,-2))
		if not clrok then clr = vec(1,1,1) end
		local data = {
			itemLine = itemLine,
			item = item,
			title = lines[2]:sub(2,-2),
			desc = lines[3]:sub(2,-2),
			clr = clr,
		}
		
		local display = skull.worldModel:newPart(id):pos((pos + vec(0.5,0.5,0.5) - skull.dir * 2.5) * 16):rot(0,skull.rot,0):light(15,15) ---@type ModelPart
		
		local title = display
		:newText("title")
		:text(('{"text":"%s","color":"#%s"}'):format(data.title,vectors.rgbToHex(data.clr.rgb)))
		:rot(0,180,0)
		:alignment("CENTER")
		:outline(true)
		:seeThrough(true)
		
		local desc = display
		:newText("desc")
		:text(data.desc)
		:rot(0,180,0)
		:alignment("CENTER")
		:outline(true)
		:seeThrough(true)
		
		local icon
		if isItem then
			icon = display
			:newItem("icon")
			:item(data.item)
			:displayMode("FIXED")
		else
			if itemLine:find("^@") then
				itemLine = 'player_head{"SkullOwner":"'..itemLine:sub(2,-1)..'"}'
			end
			icon = display
			:newText("icon")
			:text(itemLine)
			:rot(0,180,0)
			:alignment("CENTER")
			:outline(true)
		end
		
		applyTransforms(title,desc,icon,0)
		
		nodes[id] = {
			data = data,
			display = {
				title = title,
				desc = desc,
				icon = icon
			}
		}
	end
	
	skull.data.nodes = nodes
end

local cpos,cdir

skullType.firstTick = function (skull)
	cpos = client:getCameraPos()
	cdir = client:getCameraDir()
end


skullType.tick = function (skull)
	local dir = skull.dir
	local pos = skull.pos
	local hit = ray2PlaneIntersection(cpos,cdir,pos-dir*2,dir)
	if hit and skull.dir:dot(cdir) > 0 then
		hit = hit:floor()+skull.dir*2
		if hit ~= skull.data.lastHit then
			local hitID = toID(hit)
			--particles["end_rod"]:pos(hit + vec(0.5,0.5,0.5) - dir * 0.5):spawn()
			local node = skull.data.nodes[hitID]
			if node then
			tween.tweenFunction(0,1,0.4,"outBack",function (t)
					applyTransforms(
						node.display.title,
						node.display.desc,
						node.display.icon,t
					)
				end,nil,hitID)
			end
			if skull.data.lastHit then
				local lastHitID = toID(skull.data.lastHit)
				local lastNode = skull.data.nodes[lastHitID]
				if lastNode then
					tween.tweenFunction(1,0,0.8,"outBack",function (t)
						applyTransforms(
							lastNode.display.title,
							lastNode.display.desc,
							lastNode.display.icon,t
						)
					end,nil,lastHitID)
				end
			end
			skull.data.lastHit = hit
		end
	end
end