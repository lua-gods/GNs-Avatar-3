--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / Simple system for macros
/ /_/ / /|  / by macros I mean a instantiatable process.
\____/_/ |_/ Source: link]]
---@class Macro
---@field instantiate fun(events:Macro.Events)
---@field isActive boolean
---@field sync boolean
---@field name string
---@field keybind GNUI.InputEvent
---@field toggle boolean
local Macro = {}
Macro.__type = "Macro"
Macro.__index = Macro

local isHost = host:isHost()

---@class Macro.Events
---@field TICK function?
---@field WORLD_RENDER fun(deltaFrame:number, deltaTick:number)?
---@field RENDER fun(deltaTick:number, ctx:table, matrix:table)?
---@field EXIT function?

---@type Macro[]
local macros = {} -- list of registered macros

---@param name string
---@param init fun(events:Macro.Events)
---@param sync boolean?
---@return table
function Macro.new(name,init,sync)
  config:setName("GN-macros-"..avatar:getName())
  local self = {
    instantiate = init,
    name = name,
    sync = sync,
  }
  setmetatable(self,Macro)
  macros[name] = self
  if isHost then
    self.isActive = config:load(name..".isActive") and true or false
    self.keybind = config:load(name..".keybind")
    self.toggle = config:load(name..".toggle")
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

events.RENDER:register(function (delta, ctx, matrix)
  for _, value in pairs(activeInstances) do
    if value.RENDER then
      value.RENDER(delta,ctx,matrix)
    end
  end
end)

events.WORLD_TICK:register(function ()
  for key, value in pairs(activeInstances) do if value.TICK then value.TICK() end end
end)

local queueSync = {}

local function sync(id,state)
  queueSync[#queueSync+1] = {id,state}
end


if isHost then
  local timer = 0
  local waitTime = 60
  events.WORLD_TICK:register(function ()
    if host:isAvatarUploaded() and #queueSync > 0 then
      timer = timer + 1
      if timer > waitTime then
        waitTime = 5
        timer = 0
        local data = queueSync[#queueSync]
        pings.syncMacro(data[1],data[2])
        queueSync[#queueSync] = nil
      end
    end
  end,"MacroStartupWait")
end

function pings.syncMacro(id,state)
  if not isHost then
    macros[id]:setActive(state)
  end
end

---@param active boolean
function Macro:setActive(active)
  if active ~= self.isActive then
    if isHost then
      sync(self.name,active)
    end
    if active then
      if not self.instance then
        local events = {}
        self.instantiate(events)
        self.instance = events
        self.instanceID = #activeInstances+1
        activeInstances[self.instanceID] = events
      end
    else
      if self.instance then
        if self.instance.EXIT then self.instance.EXIT() end
        activeInstances[self.instanceID] = nil
        self.instance = nil
      end
    end
    self.isActive = active
  end
end

return Macro