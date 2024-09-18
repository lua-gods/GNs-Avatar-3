---@diagnostic disable: assign-type-mismatch

local cfg = require("GNUI.config")
local gnui = require("GNUI.main")

local container = gnui.Container
local element = gnui.Element

---@class GNUI.Stack : GNUI.Container
---@field isHorizontal boolean
---@field containChildren boolean
---@field Margin number
local Stack = {}

Stack.__index = function (t,i)
  return rawget(t,"parent_class") and rawget(t._parent_class,i) or rawget(t,i) or Stack[i] or container[i] or element[i]
end
Stack.__type = "GNUI.Element.Container.Stack"

---@return GNUI.Stack
function Stack.new()
  ---@type GNUI.Stack
  local new = container.new()
  new._parent_class = Stack
  new.isHorizontal = false
  new.containChildren = true
  new.Margin = 1
  ---@param child GNUI.any
  new.CHILDREN_ADDED:register(function (child)
    child.SIZE_CHANGED:register(function (size)
      new:update()
    end,"stack"..new.id)
    new:update()
  end)
  
  ---@param child GNUI.any
  new.CHILDREN_REMOVED:register(function (child)
    child.SIZE_CHANGED:remove("stack"..new.id)
    new:update()
  end)
  return new
end

function Stack:_update()
  local sizes = {}
  for i, child in pairs(self.Children) do
    local min = child:getMinimumSize()
    sizes[i] = min
  end
  if self.isHorizontal then
    local x = 0
    for i, child in pairs(self.Children) do
      child:setDimensions(x,0,x+sizes[i].x,0):setAnchor(0,0,0,1)
      x = x + sizes[i].x + self.Margin
    end
    if self.containChildren then
      self:setSystemMinimumSize(x,0)
    else
      self:setSystemMinimumSize(0,0)
    end
  else
    local y = 0
    for i, child in pairs(self.Children) do
      child:setDimensions(0,y,0,y+sizes[i].y):setAnchor(0,0,1,0)
      y = y + sizes[i].y + self.Margin
    end
    if self.containChildren then
      self:setSystemMinimumSize(0,y)
    else
      self:setSystemMinimumSize(0,0)
    end
  end
  container._update(self)
end

---if given true, the stack will be horizontal. Vertical if otherwise.
---@generic self
---@param self self
---@return self
---@param is_horizontal boolean
function Stack:setIsHorizontal(is_horizontal)
  ---@cast self GNUI.Stack
  if self.isHorizontal ~= is_horizontal then
    self.isHorizontal = is_horizontal
    self:update()
  end
  return self
end


---set the margin between children.
---@generic self
---@param self self
---@return self
---@param margin number
function Stack:setMargin(margin)
  ---@cast self GNUI.Stack
  self.Margin = margin
  self:update()
  return self
end

---if true, this stack will resize to make the elements fit
---@param contain boolean
function Stack:setContainChildren(contain)
  self.containChildren = contain
  self:update()
end

return Stack