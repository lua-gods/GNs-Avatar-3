local eventLib = require("libraries.eventLib")
local utils = require("libraries.gnui.utils")

local debug_texture = textures['gnui_debug_outline'] or 
textures:newTexture("gnui_debug_outline",6,6)
:fill(0,0,6,6,vec(0,0,0,0))
:fill(1,1,4,4,vec(1,1,1))
:fill(2,2,2,2,vec(0,0,0,0))
local element = require("libraries.gnui.primitives.element")
local sprite = require("libraries.gnui.spriteLib")
local core = require("libraries.gnui.core")

local WORLD_RENDER = eventLib.new()
events.WORLD_RENDER:register(function (delta)
   WORLD_RENDER:invoke()
end)

---@class GNUI.container : GNUI.element    # A container is a Rectangle that represents the building block of GNUI
---@field Dimensions Vector4               # Determins the offset of each side from the final output
---@field Z number                         # Offsets the container forward(+) or backward(-) if Z fighting is occuring, also affects its children.
---@field ContainmentRect Vector4          # The final output dimensions with anchors applied. incredibly handy piece of data.
---@field DIMENSIONS_CHANGED eventLib      # Triggered when the final container dimensions has changed.
---@field SIZE_CHANGED eventLib            # Triggered when the size of the final container dimensions is different from the last tick.
---@field Anchor Vector4                   # Determins where to attach to its parent, (`0`-`1`, left-right, up-down)
---@field ANCHOR_CHANGED eventLib          # Triggered when the anchors applied to the container is changed.
---@field Sprite Ninepatch                 # the sprite that will be used for displaying textures.
---@field SPRITE_CHANGED eventLib          # Triggered when the sprite object set to this container has changed.
---@field CursorHovering boolean           # True when the cursor is hovering over the container, compared with the parent container.
---@field PRESSED eventLib                 # Triggered when `setCursor` is called with the press argument set to true
---@field INPUT eventLib                   # Serves as the handler for all inputs within the boundaries of the container.
---@field canCaptureCursor boolean         # True when the container can capture the cursor. from its parent
---@field MOUSE_PRESSENCE_CHANGED eventLib # Triggered when the state of the mouse to container interaction changes, arguments include: (hovering: boolean, pressed: boolean)
---@field MOUSE_ENTERED eventLib           # Triggered once the cursor is hovering over the container
---@field MOUSE_EXITED eventLib            # Triggered once the cursor leaves the confinement of this container.
---@field ClipOnParent boolean             # when `true`, the container will go invisible once touching outside the parent container.
---@field ScaleFactor number               # Scales the displayed sprites and its children based on the factor.
---@field AccumulatedScaleFactor number    # Scales the displayed sprites and its children based on the factor.
---@field isClipping boolean               # `true` when the container is touching outside the parent's container.
---@field isCursorHovering boolean         # `true` when the cursor is hovering over the container.
---@field isPressed boolean                # `true` when the cursor is pressed over the container.
---@field ModelPart ModelPart              # The `ModelPart` used to handle where to display debug features and the sprite.
---@field CustomMinimumSize Vector2        # Minimum size that the container will use.
---@field SystemMinimumSize Vector2        # The minimum size that the container can use, set by the container itself.
---@field GrowDirection Vector2            # The direction in which the container grows into when is too small for the parent container.
---@field _child_preprocessor function     # The function that is called before each child is processed.
---@field cache table                      # Contains data to optimize the process.
local Container = {}
Container.__index = function (t,i)
   return rawget(t,"_parent_class") and rawget(t._parent_class,i) or rawget(t,i) or Container[i] or element[i]
end
Container.__type = "GNUI.element.container"
local root_containe_count = 0
---Creates a new container.
---@return self
function Container.new()
   ---@type GNUI.container
---@diagnostic disable-next-line: assign-type-mismatch
   local new = element.new()
   setmetatable(new,Container)
   new.Dimensions = vec(0,0,0,0) 
   new.Z = 0
   new.SIZE_CHANGED = eventLib.new()
   new.ContainmentRect = vec(0,0,0,0) -- Dimensions but with margins and anchored applied
   new.Anchor = vec(0,0,0,0)
   new.ModelPart = models:newPart("container"..new.id)
   new.ClipOnParent = false
   new.isCursorHovering = false
   new.isPressed = false
   new.isClipping = false
   new.ScaleFactor = 1
   new.canCaptureCursor = true
   new.AccumulatedScaleFactor = 1
   new.INPUT = eventLib.new()
   new.DIMENSIONS_CHANGED = eventLib.new()
   new.SPRITE_CHANGED = eventLib.new()
   new.ANCHOR_CHANGED = eventLib.new()
   new.MOUSE_ENTERED = eventLib.new()
   new.MOUSE_PRESSENCE_CHANGED = eventLib.new()
   new.MOUSE_EXITED = eventLib.new()
   new.PARENT_CHANGED = eventLib.new()
   new.SystemMinimumSize = vec(0,0)
   new.GrowDirection = vec(1,1)
   models:removeChild(new.ModelPart)
   -->==========[ Internals ]==========<--
   if core.debug_visible then
      new.debug_container  = sprite.new():setModelpart(new.ModelPart):setTexture(debug_texture):setRenderType("EMISSIVE_SOLID"):setBorderThickness(3,3,3,3):setScale(core.debug_scale):setColor(1,1,1):excludeMiddle(true)
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
      new:updateDimensions()
   end)

   local function orphan()
      root_containe_count = root_containe_count + 1
      WORLD_RENDER:register(function ()
         new:_propagateUpdateToChildren()
      end,"GNUI_root_container."..new.id)
   end
   orphan()
   new.PARENT_CHANGED:register(function ()
      WORLD_RENDER:remove(new.__type.."."..new.id)
      root_containe_count = root_containe_count - 1
      if new.Parent then 
         new.ModelPart:moveTo(new.Parent.ModelPart)
      else
         new.ModelPart:getParent():removeChild(new.ModelPart)
         orphan()
      end
      new:updateDimensions()
   end)
   return new
end

---Sets the backdrop of the container.  
---note: the object dosent get applied directly, its duplicated and the clone is used instead of the original.
---@generic self
---@param self self
---@param sprite_obj Ninepatch?
---@return self
function Container:setSprite(sprite_obj)
   ---@cast self self
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
   return self
end



---Sets the flag if this container should go invisible once touching outside of its parent.
---@generic self
---@param self self
---@param clip any
---@return self
function Container:setClipOnParent(clip)
   ---@cast self GNUI.container
   self.ClipOnParent = clip
   self:updateDimensions()
   return self
end
-->====================[ Dimensions ]====================<--

---Sets the dimensions of this container.  
---x,y is top left
---z,w is bottom right  
--- if Z or W is missing, they will use X and Y instead

---@generic self
---@param self self
---@overload fun(self : self, vec : Vector4): GNUI.container
---@param x number
---@param y number
---@param w number
---@param t number
---@return self
function Container:setDimensions(x,y,w,t)
   ---@cast self GNUI.container
   local new = utils.figureOutVec4(x,y,w or x,t or y)
   self.Dimensions = new
   self:updateDimensions()
   return self
end

---Sets the position of this container
---@generic self
---@param self self
---@overload fun(self : self, vec : Vector2): GNUI.container
---@param x number
---@param y number?
---@return self
function Container:setPos(x,y)
   ---@cast self GNUI.container
   local new = utils.figureOutVec2(x,y)
   local size = self.Dimensions.zw - self.Dimensions.xy
   self.Dimensions = vec(new.x,new.y,new.x + size.x,new.y + size.y)
   self:updateDimensions()
   return self
end


---Sets the Size of this container.
---@generic self
---@param self self
---@overload fun(self : self, vec : Vector2): GNUI.container
---@param x number
---@param y number
---@return self
function Container:setSize(x,y)
   ---@cast self GNUI.container
   local size = utils.figureOutVec2(x,y)
   self.Dimensions.zw = self.Dimensions.xy + size
   self:updateDimensions()
   return self
end

---Gets the Size of this container.
---@return Vector2
function Container:getSize()
---@diagnostic disable-next-line: return-type-mismatch
   return self.ContainmentRect.zw - self.ContainmentRect.xy
end

---Sets the top left offset from the origin anchor of its parent.
---@generic self
---@param self self
---@overload fun(self : self, vec : Vector2): GNUI.container
---@param x number
---@param y number
---@return self
function Container:setTopLeft(x,y)
   ---@cast self GNUI.container
   self.Dimensions.xy = utils.figureOutVec2(x,y)
   self:updateDimensions()
   return self
end

---Sets the bottom right offset from the origin anchor of its parent.
---@generic self
---@param self self
---@overload fun(self : self, vec : Vector2): GNUI.container
---@param x number
---@param y number
---@return self
function Container:setBottomRight(x,y)
   ---@cast self GNUI.container
   self.Dimensions.zw = utils.figureOutVec2(x,y)
   self:updateDimensions()
   return self
end

---Shifts the container based on the top left.
---@overload fun(self : self, vec : Vector2): GNUI.container
---@param x number
---@param y number
---@return self
function Container:offsetTopLeft(x,y)
   ---@cast self GNUI.container
   local old,new = self.Dimensions.xy,utils.figureOutVec2(x,y)
   local delta = new-old
   self.Dimensions.xy,self.Dimensions.zw = new,self.Dimensions.zw - delta
   self:updateDimensions()
   return self
end

---Shifts the container based on the bottom right.
---@overload fun(self : self, vec : Vector2): GNUI.container
---@param z number
---@param w number
---@return self
function Container:offsetBottomRight(z,w)
   ---@cast self GNUI.container
   local old,new = self.Dimensions.xy+self.Dimensions.zw,utils.figureOutVec2(z,w)
   local delta = new-old
   self.Dimensions.zw = self.Dimensions.zw + delta
   self:updateDimensions()
   return self
end

---Checks if the given position is inside the container, in local BBunits of this container with dimension offset considered.
---@overload fun(self : self, vec : Vector2): boolean
---@param x number|Vector2
---@param y number?
---@return boolean
function Container:isPositionInside(x,y)
   ---@cast self GNUI.container
   local pos = utils.figureOutVec2(x,y)
   return (
          pos.x > self.ContainmentRect.x
      and pos.y > self.ContainmentRect.y
      and pos.x < self.ContainmentRect.z / self.ScaleFactor 
      and pos.y < self.ContainmentRect.w / self.ScaleFactor)
end

---Sets the offset of the depth for this container, a work around to fixing Z fighting issues when two elements overlap.
---@param depth number
---@generic self
---@param self self
---@return self
function Container:setZ(depth)
   ---@cast self GNUI.container
   self.Z = depth
   self:updateDimensions()
   return self
end

---If this container should be able to capture the cursor from its parent if obstructed.
---@param capture boolean
---@generic self
---@param self self
---@return self
function Container:setCanCaptureCursor(capture)
   ---@cast self GNUI.container
   self.canCaptureCursor = capture
   return self
end

---@param factor number
---@generic self
---@param self self
---@return self
function Container:setScaleFactor(factor)
   ---@cast self GNUI.container
   self.ScaleFactor = factor
   self:updateDimensions()
   return self
end


---Sets the top anchor.  
--- 0 = top part of the container is fully anchored to the top of its parent  
--- 1 = top part of the container is fully anchored to the bottom of its parent
---@param units number?
---@generic self
---@param self self
---@return self
function Container:setAnchorTop(units)
   ---@cast self GNUI.container
   self.Anchor.y = units or 0
   self:updateDimensions()
   return self
end

---Sets the left anchor.  
--- 0 = left part of the container is fully anchored to the left of its parent  
--- 1 = left part of the container is fully anchored to the right of its parent
---@param units number?
---@generic self
---@param self self
---@return self
function Container:setAnchorLeft(units)
   ---@cast self GNUI.container
   self.Anchor.x = units or 0
   self:updateDimensions()
   return self
end

---Sets the down anchor.  
--- 0 = bottom part of the container is fully anchored to the top of its parent  
--- 1 = bottom part of the container is fully anchored to the bottom of its parent
---@param units number?
---@generic self
---@param self self
---@return self
function Container:setAnchorDown(units)
   ---@cast self GNUI.container
   self.Anchor.z = units or 0
   self:updateDimensions()
   return self
end

---Sets the right anchor.  
--- 0 = right part of the container is fully anchored to the left of its parent  
--- 1 = right part of the container is fully anchored to the right of its parent  
---@param units number?
---@generic self
---@param self self
---@return self
function Container:setAnchorRight(units)
   ---@cast self GNUI.container
   self.Anchor.w = units or 0
   self:updateDimensions()
   return self
end

---Sets the anchor for all sides.  
--- x 0 <-> 1 = left <-> right  
--- y 0 <-> 1 = top <-> bottom  
---if right and bottom are not given, they will use left and top instead.
---@overload fun(self : GNUI.container, xz : Vector2, yw : Vector2): GNUI.container
---@overload fun(self : GNUI.container, rect : Vector4): GNUI.container
---@param left number
---@param top number
---@param right number?
---@param bottom number?
---@generic self
---@param self self
---@return self
function Container:setAnchor(left,top,right,bottom)
   ---@cast self GNUI.container
   self.Anchor = utils.figureOutVec4(left,top,right or left,bottom or top)
   self:updateDimensions()
   return self
end

--The proper way to set if the cursor is hovering, this will tell the container that it has changed after setting its value
---@param toggle boolean
---@generic self
---@param self self
---@return self
function Container:setIsCursorHovering(toggle)
   ---@cast self GNUI.container
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
---@overload fun(self : GNUI.container, vec : Vector2): GNUI.container
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Container:setCustomMinimumSize(x,y)
   ---@cast self GNUI.container
   if (x and y) then
      local value = utils.figureOutVec2(x,y)
      if value.x == 0 and value.y == 0 then
         self.CustomMinimumSize = nil
      else
         self.CustomMinimumSize = value
      end
   else
      self.CustomMinimumSize = nil
   end
   self.cache.final_minimum_size_changed = true
   self:updateDimensions()
   return self
end

--- x -1 <-> 1 = left <-> right  
--- y -1 <-> 1 = top <-> bottom  
--Sets the grow direction of the container
---@overload fun(self : GNUI.container, vec : Vector2): GNUI.container
---@param x number
---@param y number
---@generic self
---@param self self
---@return self
function Container:setGrowDirection(x,y)
   ---@cast self GNUI.container
   self.cache.final_minimum_size_changed = true
   self.GrowDirection = utils.figureOutVec2(x or 0,y or 0)
   self:updateDimensions()
   return self
end

---Gets the minimum size of the container.
function Container:getMinimumSize()
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

function Container:updateDimensions()
   self.UpdateQueue = true
end

function Container:_updateDimensions()
   local scale = (self.Parent and self.Parent.AccumulatedScaleFactor or 1) * self.ScaleFactor
   self.AccumulatedScaleFactor = scale
   self.Dimensions:scale(scale)
   -- generate the containment rect
   local containment_rect = self.Dimensions:copy()
   -- adjust based on parent if this has one
   local clipping = false
   local size
   if self.Parent and self.Parent.ContainmentRect then 
      local parent_scale = 1 / self.Parent.ScaleFactor
      local parent_containment = self.Parent.ContainmentRect - self.Parent.ContainmentRect.xyxy
      local anchor_shift = vec(
         math.lerp(parent_containment.x,parent_containment.z,self.Anchor.x),
         math.lerp(parent_containment.y,parent_containment.w,self.Anchor.y),
         math.lerp(parent_containment.x,parent_containment.z,self.Anchor.z),
         math.lerp(parent_containment.y,parent_containment.w,self.Anchor.w)
      ) * parent_scale * self.ScaleFactor
      containment_rect.x = containment_rect.x + anchor_shift.x
      containment_rect.y = containment_rect.y + anchor_shift.y
      containment_rect.z = containment_rect.z + anchor_shift.z
      containment_rect.w = containment_rect.w + anchor_shift.w
      
      size = vec(
         math.floor((containment_rect.z - containment_rect.x) * 100 + 0.5) / 100,
         math.floor((containment_rect.w - containment_rect.y) * 100 + 0.5) / 100
      )
      
      if self.CustomMinimumSize or (self.SystemMinimumSize.x ~= 0 or self.SystemMinimumSize.y ~= 0) then
         local final_minimum_size = vec(0,0)
         local shift = vec(0,0)
         if self.cache.final_minimum_size_changed or not self.cache.final_minimum_size then
            self.cache.final_minimum_size_changed = false
            if self.CustomMinimumSize then
               final_minimum_size.x = math.max(final_minimum_size.x,self.CustomMinimumSize.x)
               final_minimum_size.y = math.max(final_minimum_size.y,self.CustomMinimumSize.y)
            end
            if self.SystemMinimumSize then
               final_minimum_size.x = math.max(final_minimum_size.x,self.SystemMinimumSize.x)
               final_minimum_size.y = math.max(final_minimum_size.y,self.SystemMinimumSize.y)
            end
            shift = (size - (containment_rect.zw - containment_rect.xy)) * -(self.GrowDirection  * -0.5 + 0.5)
            self.cache.final_minimum_size = final_minimum_size
         else
            final_minimum_size = self.cache.final_minimum_size
         end
         containment_rect.z = math.max(containment_rect.z,containment_rect.x + final_minimum_size.x)
         containment_rect.w = math.max(containment_rect.w,containment_rect.y + final_minimum_size.y)
         
         ---@diagnostic disable-next-line: param-type-mismatch
         containment_rect:sub(shift.x,shift.y,shift.x,shift.y)
         
         size = vec(
         math.floor((containment_rect.z - containment_rect.x) * 100 + 0.5) / 100,
         math.floor((containment_rect.w - containment_rect.y) * 100 + 0.5) / 100
         )
      end
      
      -- calculate clipping
      if self.ClipOnParent then
         clipping = parent_containment.x > containment_rect.x
         or parent_containment.y > containment_rect.y
         or parent_containment.z < containment_rect.z
         or parent_containment.w < containment_rect.w
      end
   else
      size = vec(
         math.floor((containment_rect.z - containment_rect.x) * 100 + 0.5) / 100,
         math.floor((containment_rect.w - containment_rect.y) * 100 + 0.5) / 100
      )
   end

   self.ContainmentRect = containment_rect
   self.Dimensions:scale(1 / scale)
   
   if not self.cache.last_size or self.cache.last_size ~= size then
      self.SIZE_CHANGED:invoke(size)
      self.cache.last_size = size
      self.cache.size_changed = true
   else
      self.cache.size_changed = false
   end
   self.DIMENSIONS_CHANGED:invoke()

   local visible = self.cache.final_visible
   if self.ClipOnParent and visible then
      if clipping then
         visible = false
      end
   end
   
   self.ModelPart:setVisible(self.Visible)
   if visible then
      self:updateSpriteTasks()
   end
end

function Container:updateSpriteTasks(forced_resize_sprites)
   local containment_rect = self.ContainmentRect
   local unscale_self = 1 / self.ScaleFactor
   self.ModelPart
      :setPos(
         -containment_rect.x * unscale_self,
         -containment_rect.y * unscale_self,
         -((self.Z + self.ChildIndex / (self.Parent and #self.Parent.Children or 1) * 0.99) * core.clipping_margin)
      )
      if self.Sprite and self.cache.size_changed or forced_resize_sprites then
         self.Sprite
            :setSize(
               (containment_rect.z - containment_rect.x) * unscale_self,
               (containment_rect.w - containment_rect.y) * unscale_self
            )
      end
      if core.debug_visible then
      ---@diagnostic disable-next-line: undefined-field
      self.debug_container
      :setPos(
         0,
         0,
         -((self.Z + 1 + self.ChildIndex / (self.Parent and #self.Parent.Children or 1)) * core.clipping_margin) * 0.6)
         if self.cache.size_changed then
            ---@diagnostic disable-next-line: undefined-field
                  self.debug_container:setSize(
                     containment_rect.z - containment_rect.x,
                     containment_rect.w - containment_rect.y)
         end
      end
end

function Container:forceUpdate()
   self:_updateDimensions()
end

function Container:_propagateUpdateToChildren(force_all)
   if self.UpdateQueue or force_all then
      force_all = true
      self.UpdateQueue = false
      self:forceUpdate()
   end
   for key, value in pairs(self.Children) do
      value:_propagateUpdateToChildren(force_all)
   end
end

return Container