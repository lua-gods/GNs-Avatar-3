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


function Stack:updateDimensions()
   local size = vec(0,0)
   local minimum_sizes = {}
   for i, child in pairs(self.Children) do
      if child.cache.final_minimum_size_changed or not child.cache.final_minimum_size then
         child.cache.final_minimum_size_changed = false
         local min = child:getSize()
         size = size + min
         minimum_sizes[i] = min
      else
         minimum_sizes[i] = child.cache.final_minimum_size
      end
   end
   self:_updateDimensions()
   if not self.cache.final_stack_size or self.cache.final_stack_size ~= size then
      self.cache.final_stack_size = size
      self.SystemMinimumSize = vec(0,size.y)
      local y = 0
      for i, child in pairs(self.Children) do
         child:setDimensions(0,y,0,y):setAnchor(0,0,1,0)
         y = y + minimum_sizes[i].y + self.Margin
         child:updateDimensions()
      end
   end
end

function Stack.new()
   ---@type GNUI.stack
   local new = container.new()
   new._parent_class = Stack
   new.type = "stack"
   new.Margin = 1
   return new
end



return Stack