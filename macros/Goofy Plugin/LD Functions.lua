---@diagnostic disable: param-type-mismatch
local Macros = require("scriptHost.macros")

local DISABLED = false

---Adds velocity to the player.
---@param x integer | Vector3 
---@param y integer?
---@param z integer?
local function LD_AddVelocity(x, y, z)
	if DISABLED then return end
	local velocity
	if type(x) == "number" then
		velocity = vec(x, y, z)
	else
		velocity = x
	end
	if host:isHost() then goofy:setVelocity(player:getVelocity() + velocity) end
end
avatar:store("LD_AddVelocity", LD_AddVelocity)

--- Sets the position of the player.
---@param x integer | Vector3 
---@param y integer?
---@param z integer?
local function LD_SetPos(x, y, z)
	if DISABLED then return end
	local pos
	if type(x) == "number" then
		pos = vec(x, y, z)
	else
		pos = x
	end
	if host:isHost() then goofy:setPos(pos) end
end
avatar:store("LD_SetPos", LD_SetPos)

--- Sets the position of the player.
---@param x integer | Vector3 
---@param y integer?
---@param z integer?
local function LD_ThrowToPos(x, y, z)
	if DISABLED then return end
	local pos
	if type(x) == "number" then
		pos = vec(x, y, z)
	else
		pos = x
	end
	if host:isHost() then goofy:setVelocity(pos - player:getPos()) end
end
avatar:store("LD_ThrowToPos", LD_ThrowToPos)
avatar:store("setpos", LD_ThrowToPos) -- backward compat

return Macros.new("LDFunctions", function(events)
	DISABLED = false
	function events.EXIT() DISABLED = true end
end), "enabled LD functions"
