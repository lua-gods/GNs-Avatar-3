-- FROM: auriafoxgirl (note: old library)
local lib = {}

---@class EventLib
local meta = {__type = "Event", __index = {}}
local event = {__index = {}}
meta.__index = meta

---@return EventLib
function lib.new()
  return setmetatable({subscribers = {}}, meta)
end
---@return EventLib
function lib.newEvent()
  return setmetatable({subscribers = {}}, meta)
end

function lib.table(tbl)
  return setmetatable({_table = tbl or {}}, event)
end

---Registers an event
---@param func function
---@param name string?
function meta:register(func, name)
  if name then
    self.subscribers[name] = {func = func}
  else
    table.insert(self.subscribers, {func = func})
  end
end

---Clears all event
function meta:clear() self.subscribers = {} end

---Removes an event with the given name.
---@param match string
function meta:remove(match) self.subscribers[match] = nil end

---Returns how much listerners there are.
---@return integer
function meta:getRegisteredCount() return #self.subscribers end

function meta:__call(...) local returnValue = {} for _, data in pairs(self.subscribers) do table.insert(returnValue, {data.func(...)}) end return returnValue end

function meta:invoke(...) local returnValue = {} for _, data in pairs(self.subscribers) do table.insert(returnValue, {data.func(...)}) end return returnValue end

function meta:__len() return #self.subscribers end

-- events table
function event.__index(t, i) return t._table[i] or (type(i) == "string" and getmetatable(t._table[i:upper()]) == meta) and t._table[i:upper()] or nil end

function event.__newindex(t, i, v)
  if type(i) == "string" and type(v) == "function" and t._table[i:upper()] and getmetatable(t._table[i:upper()]) == meta then t._table[i:upper()]:register(v)
  else t._table[i] = v end
end

function event.__ipairs(t) return ipairs(t._table) end
function event.__pairs(t) return pairs(t._table) end

-- return library
return lib