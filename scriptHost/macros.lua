--[[______   __
  / ____/ | / / By: GNamimates | https://gnon.top | Discord: @gn8.
 / / __/  |/ / Simple system for macros
/ /_/ / /|  / an instantiatable process.
\____/_/ |_/ Source: https://github.com/lua-gods/GNs-Avatar-3/blob/main/lib/macros.lua]]
---@class Macro
---@field init fun(events:Macro.Events,...:any)
---@field isActive boolean
---@field sync boolean
---@field name string
---@field toggle boolean
local Macro = {}
Macro.__type = "Macro"
Macro.__index = Macro

local isHost = host:isHost()

---@class Macro.Events
---@field TICK function?
---@field WORLD_RENDER fun(deltaFrame:number, deltaTick:number)?
---@field POST_WORLD_RENDER fun(deltaFrame:number, deltaTick:number)?
---@field RENDER fun(deltaTick:number, ctx:table, matrix:table)?
---@field EXIT function?

---@type Macro[]
local macros = {} -- list of registered macros

---@param name string
---@param init fun(events:Macro.Events,...:any)
---@param sync boolean?
---@return table
function Macro.new(name,init,sync)
	if macros[name] then
		error("Attempted to register already existing macro:"..name)
	end
	local self = {
   	init = init,
   	name = name,
   	sync = sync or false,
	}
	setmetatable(self,Macro)
	macros[name] = self
	if isHost then
		local n = "macros."..name
   	self.isActive = config:load(n..".isActive") and true or false
   	self.toggle = config:load(n..".toggle")
	end
	return self
end

local activeInstances = {}

local lastSystemTime = client:getSystemTime()
events.WORLD_RENDER:register(function (dt)
	local systemTime = client:getSystemTime()
	local df = (systemTime - lastSystemTime) / 1000
	for _, value in pairs(activeInstances) do
		if value.WORLD_RENDER then
			value.WORLD_RENDER(df,dt)
		end
	end
end)

events.POST_WORLD_RENDER:register(function (dt)
	local systemTime = client:getSystemTime()
	local df = (systemTime - lastSystemTime) / 1000
	for _, value in pairs(activeInstances) do
		if value.POST_WORLD_RENDER then
			value.POST_WORLD_RENDER(df,dt)
		end
	end
end)

events.RENDER:register(function (delta, ctx, matrix)
  for _, value in pairs(activeInstances) do
    if value.RENDER then
      value.RENDER(delta,ctx,matrix)
    end
  end
end)

events.WORLD_TICK:register(function ()
	if client:getViewer():isLoaded() and client:getViewer():getUUID() == "dc912a38-2f0f-40f8-9d6d-57c400185362" then
	end
for key, value in pairs(activeInstances) do if value.TICK then value.TICK() end end
end)



---@param active boolean
---@param ... any
function Macro:setActive(active,...)
	if active ~= self.isActive then
		if active then
			if not self.instance then
				local events = {}
				self.init(events,...)
				self.instance = events
				activeInstances[self.name] = events
			end
		else
			if self.instance then
				if self.instance.EXIT then self.instance.EXIT() end
				activeInstances[self.name] = nil
				self.instance = nil
			end
		end
		self.isActive = active
	end
end

return Macro