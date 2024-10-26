--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / Simple system for macros
/ /_/ / /|  / by macros I mean a instantiatable process.
\____/_/ |_/ Source: link]]
---@class Macro
---@field instantiate fun(events:Macro.Events)
---@field isActive boolean
local Macro = {}
Macro.__type = "Macro"
Macro.__index = Macro

---@class Macro.Events
---@field TICK function?
---@field FRAME fun(deltaFrame:number, deltaTick:number)?
---@field EXIT function?

---@type Macro[]
local macros = {} -- list of registered macros

---@param init fun(events:Macro.Events)
---@param sync boolean?
---@return table
function Macro.new(init,sync)
  local i = #macros+1
  local self = {
    instantiate = init,
    i = i,
    sync = sync,
    isActive = false,
  }
  setmetatable(self,Macro)
  macros[i] = self
  return self
end

local activeInstances = {}

local lastSystemTime = client:getSystemTime()
events.WORLD_RENDER:register(function (dt)
  local systemTime = client:getSystemTime()
  local df = (systemTime - lastSystemTime) / 1000
  for _, value in pairs(activeInstances) do
    if value.FRAME then
      value.FRAME(df,dt)
    end
  end
end)

events.WORLD_TICK:register(function ()
  for key, value in pairs(activeInstances) do if value.TICK then value.TICK() end end
end)

function pings.syncMacro(id)
  macros[id]:setActive(id)
end

---@param active boolean
function Macro:setActive(active)
  if active ~= self.isActive then
    if active then
      local events = {}
      self.instantiate(events)
      self.instance = events
      self.instanceID = #activeInstances+1
      activeInstances[self.instanceID] = events
    else
      if self.instance.EXIT then self.instance.EXIT() end
      activeInstances[self.instanceID] = nil
      self.instance = nil
    end
    self.isActive = active
  end
end

return Macro