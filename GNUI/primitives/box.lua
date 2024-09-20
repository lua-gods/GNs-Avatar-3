---@diagnostic disable: param-type-mismatch, return-type-mismatch
local cfg = require"GNUI.config"
local eventLib,utils = cfg.event, cfg.utils

local debugTex = textures['gnui_debug_outline'] or 
textures:newTexture("gnui_debug_outline",6,6)
:fill(0,0,6,6,vec(0,0,0,1))
:fill(1,1,4,4,vec(1,1,1))
:fill(2,2,2,2,vec(0,0,0,1))
local sprite = require"GNUI.ninepatch"

local nextID = 0

---@class GNUI.Box  # A box is a Rectangle that represents the building block of GNUI
--- ============================ CHILD MANAGEMENT ============================
---@field name string                      # An optional property used to get the element by a name.
---@field id integer                       # A unique integer for this element. (next-free based).
---@field Visible boolean                  # `true` to see.
---@field Parent GNUI.any                  # the element's parents.
---@field Children table<any,GNUI.any>     # A list of the element's children.
---@field ChildIndex integer               # the element's place order on its parent.
---@field VISIBILITY_CHANGED eventLib      # on change of visibility.
---@field CHILDREN_ADDED eventLib          # when a child is added. first parameter is the child added.
---@field CHILDREN_REMOVED eventLib        # when a child is removed. first parameter is the child removed.
---@field PARENT_CHANGED table             # when the parent changes.
---@field isFreed boolean                  # true when the element is being freed.
---@field ON_FREE eventLib                 # when the element is wiped from history.
--- ============================ POSITIONING ============================
---@field Dimensions Vector4               # Determins the offset of each side from the final output
---@field DIMENSIONS_CHANGED eventLib      # Triggered when the final box dimensions has changed.
---
---@field ContainmentRect Vector4          # The final output dimensions with anchors applied. incredibly handy piece of data.
---@field Z number                         # Offsets the box forward(+) or backward(-) if Z fighting is occuring, also affects its children.
---@field ZSquish number                   # Multiplies how much the modelpart is positioned in the Z axis
---@field Size Vector2                     # The size of the container.
---@field SIZE_CHANGED eventLib            # Triggered when the size of the final box dimensions is different from the last tick.
---
---@field Anchor Vector4                   # Determins where to attach to its parent, (`0`-`1`, left-right, up-down)
---@field ANCHOR_CHANGED eventLib          # Triggered when the anchors applied to the box is changed.
---
---@field CustomMinimumSize Vector2        # Minimum size that the box will use.
---@field SystemMinimumSize Vector2        # The minimum size that the box can use, set by the box itself.
---@field GrowDirection Vector2            # The direction in which the box grows into when is too small for the parent container.
---@field offsetChildren Vector2           # Shifts the children.
---
---@field ScaleFactor number               # Scales the displayed sprites and its children based on the factor.
---@field AccumulatedScaleFactor number    # Scales the displayed sprites and its children based on the factor.
--- ============================ TEXT ============================
---@field Text table                       # The text to be displayed.
---@field DefaultColor Vector3             # The color to be used when the text color is not specified.
---@field TextAlign Vector2                # The alignment of the text within the box.
---@field TextWrap boolean                 # `true` to enable text wrapping.
--- ============================ RENDERING ============================
---@field ModelPart ModelPart              # The `ModelPart` used to handle where to display debug features and the sprite.
---@field Sprite Ninepatch                    # the sprite that will be used for displaying textures.
---@field SPRITE_CHANGED eventLib          # Triggered when the sprite object set to this box has changed.
---
--- ============================ INPUTS ============================
---@field CursorHovering boolean           # True when the cursor is hovering over the container, compared with the parent container.
---@field INPUT eventLib                   # Serves as the handler for all inputs within the boundaries of the container.
---@field canCaptureCursor boolean         # True when the box can capture the cursor. from its parent
---@field MOUSE_MOVED eventLib             # Triggered when the mouse position changes within this container
---@field MOUSE_PRESSENCE_CHANGED eventLib # Triggered when the state of the mouse to box interaction changes, arguments include: (hovering: boolean, pressed: boolean)
---@field MOUSE_ENTERED eventLib           # Triggered once the cursor is hovering over the container
---@field MOUSE_EXITED eventLib            # Triggered once the cursor leaves the confinement of this container.
---@field isPressed boolean                # `true` when the cursor is pressed over the container.
---@field isCursorHovering boolean         # `true` when the cursor is hovering over the container.
---
--- ============================ CLIPPING ============================
---@field ClipOnParent boolean      # when `true`, the box will go invisible once touching outside the parent container.
---@field isClipping boolean       # `true` when the box is touching outside the parent's container.
---
--- ============================ MISC ============================
---@field cache table          # Contains data to optimize the process.
---
--- ============================ CANVAS ============================
---@field Canvas GNUI.Canvas       # The canvas that the box is attached to.
---@field CANVAS_CHANGED eventLib     # Triggered when the canvas that the box is attached to has changed. first argument is the new, second is the old one.
local Box = {}
Box.__index = function (t,i)
  return rawget(t,"_parent_class") and rawget(t._parent_class,i) or rawget(t,i) or Box[i]
end
Box.__type = "GNUI.Element.Container"
local root_container_count = 0
---Creates a new container.
---@return self
function Box.new()
  ---@type GNUI.Box
  local new = setmetatable({
    -->====================[ Child Management ]====================<--
    id = nextID,
    Visible = true,
    cache = {final_visible = true},
    VISIBILITY_CHANGED = eventLib.new(),
    Children = {},
    ChildIndex = 0,
    CHILDREN_ADDED = eventLib.new(),
    CHILDREN_REMOVED = eventLib.new(),
    PARENT_CHANGED = eventLib.new(),
    isFreed = false,
    ON_FREE = eventLib.new(),
    -->====================[ Positioning ]====================<--
    Dimensions = vec(0,0,0,0) ,
    DIMENSIONS_CHANGED = eventLib.new(),
    
    ContainmentRect = vec(0,0,0,0),
    Z = 1,
    ZSquish = 1,
    Size = vec(0,0),
    SIZE_CHANGED = eventLib.new(),
    
    Anchor = vec(0,0,0,0),
    ANCHOR_CHANGED = eventLib.new(),
    
    SystemMinimumSize = vec(0,0),
    GrowDirection = vec(1,1),
    offsetChildren = vec(0,0),
    
    ScaleFactor = 1,
    AccumulatedScaleFactor = 1,
    
    -->====================[ Text ]====================<--
    TextAlign = vec(0,0),
    TextWrap = true,
    -->====================[ Rendering ]====================<--
    ModelPart = models:newPart("GNUIBox"..nextID),
    SPRITE_CHANGED = eventLib.new(),
    
    -->====================[ Inputs ]====================<--
    INPUT = eventLib.new(),
    canCaptureCursor = true,
    MOUSE_MOVED = eventLib.new(),
    MOUSE_PRESSENCE_CHANGED = eventLib.new(),
    MOUSE_ENTERED = eventLib.new(),
    MOUSE_EXITED = eventLib.new(),
    isPressed = false,
    isCursorHovering = false,
    
    -->====================[ Clipping ]====================<--
    ClipOnParent = false,
    isClipping = false,
    -->====================[ Canvas ]====================<--
    CANVAS_CHANGED = eventLib.new(),
  },Box)
  

  nextID = nextID + 1
  models:removeChild(new.ModelPart)
  
  -->==========[ Internals ]==========<--
  if cfg.debug_mode then
   new.debug_container = sprite.new():setModelpart(new.ModelPart):setTexture(debugTex):setRenderType("CUTOUT_EMISSIVE_SOLID"):setBorderThickness(3,3,3,3):setScale(cfg.debug_scale):excludeMiddle(true)
   new.MOUSE_PRESSENCE_CHANGED:register(function (hovering,pressed)
    if pressed then
      new.debug_container:setColor(0.5,0.5,0.1)
    else
      new.debug_container:setColor(1,1,hovering and 0.25 or 1)
    end
   end)
  end

  ---@param event GNUI.InputEvent
  new.INPUT:register(function (event)
   if event.key == "key.mouse.left" and event.isPressed then
    if new.isCursorHovering then
      if not new.isPressed then
       new.isPressed = true
       new.MOUSE_PRESSENCE_CHANGED:invoke(new.isCursorHovering,true)
      end
    end
   else
    if new.isPressed then
      new.isPressed = false
      new.MOUSE_PRESSENCE_CHANGED:invoke(new.isCursorHovering,false)
    end
   end
  end)
  
  new.VISIBILITY_CHANGED:register(function (v)
   new:update()
  end)
  
  new.ON_FREE:register(function ()
   new.ModelPart:remove()
   new.isFreed = true
  end)

  local function orphan()
   root_container_count = root_container_count + 1
  end
  orphan()
  new.PARENT_CHANGED:register(function (parent)
   if parent then
    if parent.__type:find("Canvas$") then
      new:setCanvas(parent)
    else
      new:setCanvas(parent.Canvas)
    end
   else
    new:setCanvas(nil)
   end
   root_container_count = root_container_count - 1
   if new.Parent then 
    new.ModelPart:moveTo(new.Parent.ModelPart)
   else
    new.ModelPart:getParent():removeChild(new.ModelPart)
    orphan()
   end
   new:update()
  end)
  return new
end

---Sets the visibility of the element and its children
---@param visible boolean
---@generic self
---@param self self
---@return self
function Box:setVisible(visible)
  ---@cast self GNUI.Box
  if self.Visible ~= visible then
    self.Visible = visible
    self.VISIBILITY_CHANGED:invoke(visible)
    for key, child in pairs(self.Children) do
      child:_updateVisibility()
    end
    if not self.Parent then
      self:_updateVisibility()
    end
  end
  return self
end

function Box:_updateVisibility()
  if self.Parent then
    self.cache.final_visible = self.Parent.Visible and self.Visible
  else
    self.cache.final_visible = self.Visible
  end
  return self
end

---Sets the name of the element. this is used to make it easier to find elements with getChild
---@param name string
---@generic self
---@param self self
---@return self
function Box:setName(name)
  ---@cast self GNUI.Box
  self.name = name
  return self
end

---@return string
function Box:getName()
  return self.name
end

---Gets a child by username
---@param name string
---@return GNUI.any
function Box:getChild(name)
  for _, child in pairs(self.Children) do
    if child.name and child.name == name then
      return child
    end
  end
  return self
end

function Box:getChildByIndex(index)
  return self.Children[index]
end

---@generic self
---@param self self
---@return self
function Box:updateChildrenOrder()
  ---@cast self GNUI.Box
  for i, c in pairs(self.Children) do
    c.ChildIndex = i
  end
  return self
end

---Adopts an element as its child.
---@param child GNUI.any
---@param index integer?
---@generic self
---@param self self
---@return self
function Box:addChild(child,index)
  ---@cast self GNUI.Box
  if not child then return self end
  if not type(child):find("^GNUI.") then
    error("invalid element given, recived: "..type(child),2)
  end
  if child.Parent then return self end
  table.insert(self.Children, index or #self.Children+1, child)
  if child.Parent ~= self then
    local old_parent = child.Parent
    child.Parent = self
    child.PARENT_CHANGED:invoke(self,old_parent)
    self.CHILDREN_ADDED:invoke(child)
  end
  self:updateChildrenIndex()
  return self
end

---Abandons the child into the street.
---@param child GNUI.Box
---@generic self
---@param self self
---@return self
function Box:removeChild(child)
  ---@cast self GNUI.Box
  if child.Parent == self then -- birth certificate check
    table.remove(self.Children, child.ChildIndex)
    child.ChildIndex = 0
    if child.Parent then
      local old_parent = child.Parent
      child.Parent = nil
      child.PARENT_CHANGED:invoke(nil,old_parent)
      self.CHILDREN_REMOVED:invoke(child)
    end
    self:updateChildrenIndex()
  else
    error("This container, is, not, the father", 2)
  end
  return self
end

---@return table<integer, GNUI.Box|GNUI.Box>
function Box:getChildren()
  return self.Children
end

---@generic self
---@param self self
---@return self
function Box:updateChildrenIndex()
  ---@cast self GNUI.Box
  for i = 1, #self.Children, 1 do
    local child = self.Children[i]
    child.ChildIndex = i
    if child.update then
      child:update()
    end
  end
  return self
end

---Sets the Child Index of the element.
---@param i any
function Box:setChildIndex(i)
  if self.Parent then
    i = math.clamp(i, 1, #self.Parent.Children)
    table.remove(self.Parent.Children, self.ChildIndex)
    table.insert(self.Parent.Children, i, self)
    self.Parent:updateChildrenIndex()
    self.Parent:update()
  end
end

---Frees all the data of the element. all thats left to do is to forget it ever existed.
function Box:free()
  if self.Parent then
    self.Parent:removeChild(self)
  end
  self.ON_FREE:invoke()
end

---Kills all the children, go startwars mode.
function Box:purgeAllChildren()
  local children = {}
  for key, value in pairs(self:getChildren()) do
    children[key] = value
  end
  for key, value in pairs(children) do
    value:free()
  end
  self.Children = {}
end

---Kills all the children in the given number range.
---@param ifrom any
---@param ito any
function Box:purgeChildrenRange(ifrom,ito)
  local children = {}
  for i = math.max(ifrom,1), math.min(ito, #self.Children), 1 do
    children[i] = self.Children[i]
  end
  for key, value in pairs(children) do
    value:free()
  end
end

---Sets the canvas of this box and its hierarchy.
---@package
---@param canvas GNUI.Canvas
---@generic self
---@param self self
---@return self
function Box:setCanvas(canvas)
  ---@cast self self
  if self.Canvas ~= canvas then
   local old = self.Canvas
   self.Canvas = canvas
   self.CANVAS_CHANGED:invoke(canvas,old)
   for i = 1, #self.Children, 1 do
    local child = self.Children[i]
    child:setCanvas(canvas)
   end
  end
  return self
end

---Sets the backdrop of the container.  
---Note: if the sprite given is already in use, it will overtake it.
---@generic self
---@param self self
---@param sprite_obj Ninepatch?
---@return self
function Box:setSprite(sprite_obj)
  ---@cast self self
  if sprite_obj ~= self.Sprite then
   if self.Sprite then
    self.Sprite:deleteRenderTasks()
    self.Sprite = nil
   end
   if sprite_obj then
    self.Sprite = sprite_obj
    sprite_obj:setModelpart(self.ModelPart)
   end
   self:updateSpriteTasks(true)
   self.SPRITE_CHANGED:invoke()
  end
  return self
end



---Sets the flag if this box should go invisible once touching outside of its parent.
---@generic self
---@param self self
---@param clip any
---@return self
function Box:setClipOnParent(clip)
  ---@cast self GNUI.Box
  self.ClipOnParent = clip
  self:update()
  return self
end
-->====================[ Dimensions ]====================<--

---Sets the dimensions of this container.  
---x,y is top left  
---z,w is bottom right  
--- if Z or W is missing, they will use X and Y instead
---@generic self
---@param self self
---@overload fun(self : self, vec : Vector4): GNUI.Box
---@param x number
---@param y number
---@param w number
---@param t number
---@return self
function Box:setDimensions(x,y,w,t)
  ---@cast self GNUI.Box
  local new = utils.figureOutVec4(x,y,w or x,t or y)
  self.Dimensions = new
  self:update()
  return self
end

---Sets the position of this container
---@generic self
---@param self self
---@overload fun(self : self, vec : Vector2): GNUI.Box
---@param x number
---@param y number?
---@return self
function Box:setPos(x,y)
  ---@cast self GNUI.Box
  local new = utils.vec2(x,y)
  local size = self.Dimensions.zw - self.Dimensions.xy
  self.Dimensions = vec(new.x,new.y,new.x + size.x,new.y + size.y)
  self:update()
  return self
end


---Sets the Size of this container.
---@generic self
---@param self self
---@overload fun(self : self, vec : Vector2): GNUI.Box
---@param x number
---@param y number
---@return self
function Box:setSize(x,y)
  ---@cast self GNUI.Box
  local size = utils.vec2(x,y)
  self.Dimensions.zw = self.Dimensions.xy + size
  self:update()
  return self
end

---Gets the Size of this container.
---@return Vector2
function Box:getSize()
---@diagnostic disable-next-line: return-type-mismatch
  return self.ContainmentRect.zw - self.ContainmentRect.xy
end


---Checks if the given position is inside the container, in local BBunits of this box with dimension offset considered.
---@overload fun(self : self, vec : Vector2): boolean
---@param x number|Vector2
---@param y number?
---@return boolean
function Box:isPosInside(x,y)
  ---@cast self GNUI.Box
  local pos = utils.vec2(x,y)
  return (
     pos.x > self.ContainmentRect.x
   and pos.y > self.ContainmentRect.y
   and pos.x < self.ContainmentRect.z / self.ScaleFactor 
   and pos.y < self.ContainmentRect.w / self.ScaleFactor)
end

---Multiplies the offset from its parent container, useful for making the future elements go behind the parent by setting this value to lower than 0.
---@param mul number
---@generic self
---@param self self
---@return self
function Box:setZMul(mul)
  ---@cast self GNUI.Box
  self.Z = mul
  self:update()
  return self
end

---If this box should be able to capture the cursor from its parent if obstructed.
---@param capture boolean
---@generic self
---@param self self
---@return self
function Box:setBlockMouse(capture)
  ---@cast self GNUI.Box
  self.canCaptureCursor = capture
  return self
end

---Sets the UI scale of its children, while still mentaining their original anchors and positions.
---@param factor number?
---@generic self
---@param self self
---@return self
function Box:setScaleFactor(factor)
  ---@cast self GNUI.Box
  self.ScaleFactor = factor or 1
  self:update()
  return self
end


---Sets the top anchor.  
--- 0 = top part of the box is fully anchored to the top of its parent  
--- 1 = top part of the box is fully anchored to the bottom of its parent
---@param units number?
---@generic self
---@param self self
---@return self
function Box:setAnchorTop(units)
  ---@cast self GNUI.Box
  self.Anchor.y = units or 0
  self:update()
  return self
end

---Sets the left anchor.  
--- 0 = left part of the box is fully anchored to the left of its parent  
--- 1 = left part of the box is fully anchored to the right of its parent
---@param units number?
---@generic self
---@param self self
---@return self
function Box:setAnchorLeft(units)
  ---@cast self GNUI.Box
  self.Anchor.x = units or 0
  self:update()
  return self
end

---Sets the down anchor.  
--- 0 = bottom part of the box is fully anchored to the top of its parent  
--- 1 = bottom part of the box is fully anchored to the bottom of its parent
---@param units number?
---@generic self
---@param self self
---@return self
function Box:setAnchorDown(units)
  ---@cast self GNUI.Box
  self.Anchor.z = units or 0
  self:update()
  return self
end

---Sets the right anchor.  
--- 0 = right part of the box is fully anchored to the left of its parent  
--- 1 = right part of the box is fully anchored to the right of its parent  
---@param units number?
---@generic self
---@param self self
---@return self
function Box:setAnchorRight(units)
  ---@cast self GNUI.Box
  self.Anchor.w = units or 0
  self:update()
  return self
end

---Sets the anchor for all sides.  
--- x 0 <-> 1 = left <-> right  
--- y 0 <-> 1 = top <-> bottom  
---if right and bottom are not given, they will use left and top instead.
---@overload fun(self : GNUI.Box, xz : Vector2, yw : Vector2): GNUI.Box
---@overload fun(self : GNUI.Box, rect : Vector4): GNUI.Box
---@param left number
---@param top number
---@param right number?
---@param bottom number?
---@generic self
---@param self self
---@return self
function Box:setAnchor(left,top,right,bottom)
  ---@cast self GNUI.Box
  self.Anchor = utils.figureOutVec4(left,top,right or left,bottom or top)
  self:update()
  return self
end

--The proper way to set if the cursor is hovering, this will tell the box that it has changed after setting its value
---@param toggle boolean
---@generic self
---@param self self
---@return self
function Box:setIsCursorHovering(toggle)
  ---@cast self GNUI.Box
  if self.isCursorHovering ~= toggle then
   self.isCursorHovering = toggle
   self.MOUSE_PRESSENCE_CHANGED:invoke(toggle,self.isPressed)
   if toggle then
    self.MOUSE_ENTERED:invoke()
   else
    self.MOUSE_EXITED:invoke()
   end
  end
  return self
end

--Sets the minimum size of the container. resets to none if no arguments is given
---@overload fun(self : GNUI.Box, vec : Vector2): GNUI.Box
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Box:setCustomMinimumSize(x,y)
  ---@cast self GNUI.Box
  if (x and y) then
   local value = utils.vec2(x,y)
   if value.x == 0 and value.y == 0 then
    self.CustomMinimumSize = nil
   else
    self.CustomMinimumSize = value
   end
  else
   self.CustomMinimumSize = nil
  end
  self.cache.final_minimum_size_changed = true
  self:update()
  return self
end

-- This API is only made for libraries, use `Container:setCustomMinimumSize()` instead
--Sets the minimum size of the container.  
--* this does not make the box update. `Container:update()` still needs to be called.
---@overload fun(self : GNUI.Box, vec : Vector2): GNUI.Box
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Box:setSystemMinimumSize(x,y)
  ---@cast self GNUI.Box
  if (x and y) then
   local value = utils.vec2(x,y)
   self.SystemMinimumSize = value
  else
   self.SystemMinimumSize = vec(0,0)
  end
  self.cache.final_minimum_size_changed = true
  return self
end

--- x -1 <-> 1 = left <-> right  
--- y -1 <-> 1 = top <-> bottom  
--Sets the grow direction of the container
---@overload fun(self : GNUI.Box, vec : Vector2): GNUI.Box
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Box:setGrowDirection(x,y)
  ---@cast self GNUI.Box
  self.cache.final_minimum_size_changed = true
  self.GrowDirection = utils.vec2(x or 0,y or 0)
  self:update()
  return self
end

---Sets the shift of the children, useful for scrollbars.
---@overload fun(self : GNUI.Box, vec : Vector2): GNUI.Box
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Box:setChildrenOffset(x,y)
  ---@cast self GNUI.Box
  self.offsetChildren = utils.vec2(x or 0,y or 0)
  self.cache.final_minimum_size_changed = true
  self:update()

  return self
end

---Gets the minimum size of the container.
function Box:getMinimumSize()
  local smallest = vec(0,0)
  if self.CustomMinimumSize then
   smallest = self.CustomMinimumSize
  end
  if self.SystemMinimumSize then
   smallest.x = math.max(smallest.x,self.SystemMinimumSize.x)
   smallest.y = math.max(smallest.y,self.SystemMinimumSize.y)
  end
  
  self.cache.final_minimum_size = smallest
  return smallest
end

--- Converts a point from BBunits to UV units.
---@overload fun(self : GNUI.any, pos : Vector2): Vector2
---@param x number
---@param y number
---@return Vector2
function Box:XYtoUV(x,y)
  local pos = utils.vec2(x,y)
  return vec(
   math.map(pos.x,self.Dimensions.x,self.Dimensions.z,0,1),
   math.map(pos.y,self.Dimensions.y,self.Dimensions.w,0,1)
  )
end

--- Converts a point from UV units to BB units.
---@overload fun(self : GNUI.any, pos : Vector2): Vector2
---@param x number
---@param y number
---@return Vector2
function Box:UVtoXY(x,y)
  local pos = utils.vec2(x,y)
  return vec(
   math.map(pos.x,0,1,self.Dimensions.x,self.Dimensions.z),
   math.map(pos.y,0,1,self.Dimensions.y,self.Dimensions.w)
  )
end

---returns the global position of the given local position.
---@overload fun(self : GNUI.any, pos : Vector2): Vector2
---@param x number
---@param y number
---@return Vector2
function Box:toGlobal(x,y)
  local pos = utils.vec2(x,y)
  local parent = self
  local i = 0
  while parent do
   i = i + 1
   if i > 100 then break end
   pos = pos + parent.ContainmentRect.xy
   parent = parent.Parent
  end
  return pos
end


---returns the local position of the given global position.
---@overload fun(self : GNUI.any, pos : Vector2): Vector2
---@param x number
---@param y number
---@return Vector2
function Box:toLocal(x,y)
  local pos = utils.vec2(x,y)
  local parent = self
  local i = 0
  while parent do
   i = i + 1
   if i > 100 then break end
   pos = pos - parent.ContainmentRect.xy
   parent = parent.Parent
  end
  return pos
end

---Flags this Container to be updated.
---@generic self
---@param self self
---@return self
function Box:update()
  ---@cast self GNUI.Box
  self.UpdateQueue = true
  return self
end


--- Calls the events that are most likely used by themes. ex. `MOUSE_PRESSENCE_CHANGED`
---@generic self
---@param self self
---@return self
function Box:updateTheming()
  ---@cast self GNUI.Box
  self.MOUSE_PRESSENCE_CHANGED:invoke(self.isCursorHovering,self.isPressed)
  return self
end


function Box:_update()
  local scale = (self.Parent and self.Parent.AccumulatedScaleFactor or 1) * self.ScaleFactor
  local shift = vec(0,0)
  self.AccumulatedScaleFactor = scale
  self.Dimensions:scale(scale)
  -- generate the containment rect
  local cr = self.Dimensions:copy():sub(self.Parent and self.Parent.offsetChildren.xyxy or vec(0,0,0,0))
  -- adjust based on parent if this has one
  local clipping = false
  local size
  if self.Parent and self.Parent.ContainmentRect then 
   local parent_scale = 1 / self.Parent.ScaleFactor
   local pc = self.Parent.ContainmentRect - self.Parent.ContainmentRect.xyxy
   local as = vec(
    math.lerp(pc.x,pc.z,self.Anchor.x),
    math.lerp(pc.y,pc.w,self.Anchor.y),
    math.lerp(pc.x,pc.z,self.Anchor.z),
    math.lerp(pc.y,pc.w,self.Anchor.w)
   ) * parent_scale * self.ScaleFactor
   cr.x = cr.x + as.x
   cr.y = cr.y + as.y
   cr.z = cr.z + as.z
   cr.w = cr.w + as.w
   
   size = vec(
    math.floor((cr.z - cr.x) * 100 + 0.5) / 100,
    math.floor((cr.w - cr.y) * 100 + 0.5) / 100
   )
   if self.CustomMinimumSize or (self.SystemMinimumSize.x ~= 0 or self.SystemMinimumSize.y ~= 0) then
    local fms = vec(0,0)
    
    if self.cache.final_minimum_size_changed or not self.cache.final_minimum_size then
      self.cache.final_minimum_size_changed = false
      if self.CustomMinimumSize then
       fms.x = math.max(fms.x,self.CustomMinimumSize.x)
       fms.y = math.max(fms.y,self.CustomMinimumSize.y)
      end
      if self.SystemMinimumSize then
       fms.x = math.max(fms.x,self.SystemMinimumSize.x)
       fms.y = math.max(fms.y,self.SystemMinimumSize.y)
      end
      shift = (size - (cr.zw - cr.xy) ) * -(self.GrowDirection  * -0.5 + 0.5)
      self.cache.final_minimum_size = fms
    else
      fms = self.cache.final_minimum_size
    end
    cr.z = math.max(cr.z,cr.x + fms.x)
    cr.w = math.max(cr.w,cr.y + fms.y)
    
    ---@diagnostic disable-next-line: param-type-mismatch
    cr:sub(shift.x,shift.y,shift.x,shift.y)
    local sh = self.Parent.offsetChildren
    
    size = vec(
    math.floor((cr.z - cr.x) * 100 + 0.5) / 100,
    math.floor((cr.w - cr.y) * 100 + 0.5) / 100
    )
   end
   
   -- calculate clipping
   if self.ClipOnParent then
    clipping = 
      pc.x > cr.x
    or pc.y > cr.y
    or pc.z < cr.z
    or pc.w < cr.w
   end
  else
   size = vec(
    math.floor((cr.z - cr.x) * 100 + 0.5) / 100,
    math.floor((cr.w - cr.y) * 100 + 0.5) / 100
   )
  end

  self.cache.size = size
  self.ContainmentRect = cr
  self.Dimensions:scale(1 / scale)
  self.Size = size
  if not self.cache.last_size or self.cache.last_size ~= size then
   self.SIZE_CHANGED:invoke(size,self.cache.last_size)
   self.cache.last_size = size
   self.cache.size_changed = true
  else
   self.cache.size_changed = false
  end
  self.DIMENSIONS_CHANGED:invoke()

  local visible = self.Visible
  if self.ClipOnParent and visible then
   if clipping then
    visible = false
   end
  end
  self.cache.final_visible = visible
  if self.cache.final_visible ~= self.cache.was_visible then 
   self.cache.was_visible = self.cache.final_visible
   self.ModelPart:setVisible(visible)
   if visible then
    self:updateSpriteTasks(true)
   end
  end
  if visible then
   self:updateSpriteTasks()
  end
end


function Box:updateSpriteTasks(forced_resize_sprites)
  local containment_rect = self.ContainmentRect
  local unscale_self = 1 / self.ScaleFactor
  local child_count = self.Parent and (#self.Parent.Children) or 1
  self.ZSquish = (self.Parent and self.Parent.ZSquish or 1) * (1 / child_count)
  local child_weight = self.ChildIndex / child_count
  if self.cache.final_visible then
   self.ModelPart
    :setPos(
      -containment_rect.x * unscale_self,
      -containment_rect.y * unscale_self,
      -(child_weight) * cfg.clipping_margin * self.Z * self.ZSquish
    ):setVisible(true)
    if self.Sprite and (self.cache.size_changed or forced_resize_sprites) then
      self.Sprite
       :setSize(
        (containment_rect.z - containment_rect.x) * unscale_self,
        (containment_rect.w - containment_rect.y) * unscale_self
       )
    end
  end
   if cfg.debug_mode then
   ---@diagnostic disable-next-line: undefined-field
   self.debug_container
   :setPos(
    0,
    0,
    -(((self.ChildIndex * self.Z) / (self.Parent and (#self.Parent.Children) or 1) * 0.8) * cfg.clipping_margin))
    if self.cache.size_changed then
      ---@diagnostic disable-next-line: undefined-field
        self.debug_container:setSize(
          containment_rect.z - containment_rect.x,
          containment_rect.w - containment_rect.y)
    end
   end
end

function Box:forceUpdate()
  self:_update()
  self:_propagateUpdateToChildren()
end

function Box:_propagateUpdateToChildren(force_all)
  if self.UpdateQueue or force_all then
   force_all = true -- when a box updates, make sure the children updates.
   self.UpdateQueue = false
   self:forceUpdate()
  end
  for key, value in pairs(self.Children) do
   if value.isFreed then
    self:removeChild(value)
   else
    if value then
      value:_propagateUpdateToChildren(force_all)
    end
   end
  end
end

return Box