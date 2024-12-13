---@diagnostic disable: missing-fields



---@class A
local A = {}

---@class AA : A
local AA = {}

---@generic self
---@param self self
---@return self
function A:a()
   ---@cast self AA
   return self
end

---@overload fun(self:AA,a:number):AA
---@generic self
---@param self self
---@return self
function AA:aa()
   ---@cast self A
   return self
end

local test = {} ---@type AA

test:a():aa(2):a():

