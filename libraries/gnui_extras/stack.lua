---@diagnostic disable: assign-type-mismatch
local gnui = require("libraries.gnui")

local container = require("libraries.gnui.primitives.container")
local element = require("libraries.gnui.primitives.element")

---@class GNUI.stack : GNUI.container
---@field type boolean
---@field Margin number
local Stack = {}

Stack.__index = function (t,i)
   return rawget(t,"parent_class") and rawget(t._parent_class,i) or rawget(t,i) or Stack[i] or container[i] or element[i]
end
Stack.__type = "GNUI.element.container.stack"

function Stack.new()
   ---@type GNUI.stack
   local new = container.new()
   new._parent_class = Stack
   new.type = "stack"
   new.Margin = 1
   ---@param child GNUI.any
   new.CHILDREN_ADDED:register(function (child)
      child.SIZE_CHANGED:register(function (size)
         new:updateDimensions()
      end,"stack"..new.id)
      new:updateDimensions()
   end)
   
   ---@param child GNUI.any
   new.CHILDREN_REMOVED:register(function (child)
      child.SIZE_CHANGED:remove("stack"..new.id)
      new:updateDimensions()
   end)
   return new
end

function Stack:updateDimensions()
   local size = vec(0,0)
   local sizes = {}
   for i, child in pairs(self.Children) do
      local min = child:getSize()
      size = size + min
      sizes[i] = min
   end
   self:_updateDimensions()
   
   if not self.cache.final_stack_size or self.cache.final_stack_size ~= size then
      self.cache.final_stack_size = size
      self.SystemMinimumSize = vec(0,size.y)
      local y = 0
      for i, child in pairs(self.Children) do
         child:setDimensions(0,y,0,y+sizes[i].y):setAnchor(0,0,1,0)
         y = y + sizes[i].y + self.Margin
         child:updateDimensions()
      end
   end
end

return Stack