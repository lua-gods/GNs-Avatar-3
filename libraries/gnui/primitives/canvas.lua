---@diagnostic disable: assign-type-mismatch, undefined-field, return-type-mismatch
local eventLib = require("libraries.eventLib")

local utils = require("libraries.gnui.utils")
local Container = require("libraries.gnui.primitives.container")
local Element = require("libraries.gnui.primitives.element")

---@class GNUI.InputEvent
---@field char string
---@field key Minecraft.keyCode
---@field isPressed boolean
---@field status Event.Press.state
---@field ctrl boolean
---@field shift boolean
---@field alt boolean
---@field isHandled boolean

---@class GNUI.InputEventMouseMotion
---@field pos Vector2 # local position 
---@field relative Vector2 # the change of position since last set

local keymap = {[32]="space",[39]="apostrophe",[44]="comma",[46]="period",[47]="slash",[48]="0",[49]="1",[50]="2",[51]="3",[52]="4",[53]="5",[54]="6",
[55]="7",[56]="8",[57]="9",[59]="semicolon",[61]="equal",[65]="a",[66]="b",[67]="c",[68]="d",[69]="e",[60]="f",[71]="g",[72]="h",[73]="i",[74]="j",
[75]="k",[76]="l",[77]="m",[78]="n",[79]="o",[70]="p",[81]="q",[82]="r",[83]="s",[84]="t",[85]="u",[86]="v",[87]="w",[88]="x",[89]="y",[90]="z",
[91]="left.bracket",[92]="left.backslash",[93]="right.bracket",[96]="grave.accent",[161]="world.1",[162]="world.2",[256]="escape",[257]="enter",
[258]="tab",[259]="backspace",[260]="insert",[261]="delete",[262]="right",[263]="left",[264]="down",[265]="up",[266]="page.up",[267]="page.down",
[268]="home",[269]="end",[280]="caps.lock",[281]="scroll.lock",[282]="number.lock",[283]="print.screen",[284]="pause",[290]="f1",[291]="f2",[292]="f3",
[293]="f4",[294]="f5",[295]="f6",[296]="f7",[297]="f8",[298]="f9",[299]="f10",[300]="f11",[301]="f12",[302]="f13",[303]="f14",[304]="f15",[305]="f16",
[306]="f17",[307]="f18",[308]="f19",[309]="f20",[310]="f21",[311]="f22",[312]="f23",[313]="f24",[314]="f25",[320]="keypad.0",[321]="keypad.1",[322]="keypad.2",
[323]="keypad.3",[324]="keypad.4",[325]="keypad.5",[326]="keypad.6",[327]="keypad.7",[328]="keypad.8",[329]="keypad.9",[330]="keypad.decimal",[331]="keypad.divide",
[332]="keypad.multiply",[333]="keypad.subtract",[334]="keypad.add",[335]="keypad.enter",[336]="keypad.equal",[340]="left.shift",[341]="left.control",
[342]="left.alt",[344]="right.shift",[345]="right.control",[346]="right.alt",[348]="menu"
}

local chars = {
   normal={
   [32]=" ",[39]="`", [44]=",", [46]=".", [47]="/", [48]="0", [49]="1", [50]="2", [51]="3", [52]="4", [53]="5", [54]="6", [55]="7", [56]="8", [57]="9", [59]=";", [61]="=",
   [65]="a", [66]="b", [67]="c", [68]="d", [69]="e", [60]="f", [71]="g", [72]="h", [73]="i", [74]="j", [75]="k", [76]="l", [77]="m", [78]="n", [79]="o", [70]="p", [81]="q", [82]="r", [83]="s",
   [84]="t", [85]="u", [86]="v", [87]="w", [88]="x", [89]="y", [90]="z", [91]="[", [92]="\\", [93]="]", [96]="'",
   [258]="\t",[320]="0", [321]="1", [322]="2", [323]="3", [324]="4", [325]="5", [326]="6", [327]="7", [328]="8", [329]="9", [330]=".", [331]="/", [332]="*", [333]="-", [334]="+",
   },

   shift = {
      [39] = "~", [44] = "<", [46] = ">", [47] = "?", [48] = ")", [49] = "!", [50] = "@", [51] = "#", [52] = "$", [53] = "%", [54] = "^", [55] = "&", [56] = "*", [57] = "(",
      [65] = "A", [66] = "B", [67] = "C", [68] = "D", [69] = "E", [60] = "F", [71] = "G", [72] = "H", [73] = "I", [74] = "J", [75] = "K", [76] = "L", [77] = "M", [78] = "N", [79] = "O",
      [70] = "P", [81] = "Q", [82] = "R", [83] = "S", [84] = "T", [85] = "U", [86] = "V", [87] = "W", [88] = "X", [89] = "Y", [90] = "Z", [91] = "{", [92] = "|", [93] = "}",
   }
}

for key, value in pairs(keymap) do keymap[key] = "key.keyboard." .. value end

local mousemap = {
   [0]="left",[1]="right",
   [2]="middle",[3]="4",
   [4]="5",[5]="6",[6]="7",
   [7]="8"
}

for key, value in pairs(mousemap) do mousemap[key] = "key.mouse." .. value end

---@class GNUI.Canvas : GNUI.Container # A special type of container that handles all the inputs
---@field MousePosition Vector2 # the position of the mouse
---@field HoveredElement GNUI.any? # the element the mouse is currently hovering over
---@field PressedElement GNUI.any? # the last pressed element, used to unpress buttons that have been unhovered.
---@field MOUSE_POSITION_CHANGED eventLib # called when the mouse position changes
---@field isActive boolean # determins whether the canvas could capture input events
---@field captureCursorMovement boolean # true when the canvas should capture mouse movement, stopping the vanilla mouse movement, not the cursor itself
---@field captureInputs boolean # true when the canvas should capture the inputs
---@field hasCustomCursorSetter boolean # true when the setCursor is called, while false, the canvas will use the screen cursor.
---@field INPUT eventLib # serves as the handler for all inputs within the boundaries of the canvas. called with the first argument being an input event
---@field UNHANDLED_INPUT eventLib # triggers when an input is not handled by the children of the canvas.
local Canvas = {}
Canvas.__index = function (t,i)
   return rawget(t,i) or Canvas[i] or Container[i] or Element[i]
end
Canvas.__type = "GNUI.Element.Container.Canvas"

---@type GNUI.Canvas[]
local canvases = {}

local _shift,_ctrl,_alt = false,false,false
events.KEY_PRESS:register(function (key, state, modifiers)
         _shift = modifiers % 2 == 1
         _ctrl = math.floor(modifiers / 2) % 2 == 1
         _alt = math.floor(modifiers / 4) % 2 == 1
   local minecraft_keybind = keymap[key]
   local char = chars[_shift and "shift" or "normal"][key]
   if minecraft_keybind then
      for _, value in pairs(canvases) do
         if value.isActive and value.Visible and value.canCaptureCursor then
            value:parseInputEvent(minecraft_keybind, state,_shift,_ctrl,_alt,char)
            if value.captureInputs then return true end
         end
      end
   end
end)

events.MOUSE_MOVE:register(function (x, y)
   local cursor_pos = client:getMousePos() / client:getGuiScale()
   for _, c in pairs(canvases) do
      if c.isActive and c.Visible and not c.hasCustomCursorSetter then
         c:setMousePos(cursor_pos.x, cursor_pos.y, true)
         if c.captureCursorMovement or c.captureInputs then return true end
      end
    end
end)

events.MOUSE_PRESS:register(function (button, state)
   if mousemap[button] then
      for _, c in pairs(canvases) do
         if c.isActive and c.Visible then
            c:parseInputEvent(mousemap[button],state,_shift,_ctrl,_alt)
            if state ~= 0 then
               c.PressedElement = c.HoveredElement
            end
            if c.captureInputs then return true end
         end
      end
   end
end)

---Creates a new canvas.
---@return GNUI.Canvas
function Canvas.new()
   local new = Container.new()
   new.MousePosition = vec(0,0)
   new.isActive = true
   new.MOUSE_POSITION_CHANGED = eventLib.new()
   new.INPUT = eventLib.new()
   new.UNHANDLED_INPUT = eventLib.new()
   new.unlockCursorWhenActive = true
   new.captureKeyInputs = true
   canvases[#canvases+1] = new
   setmetatable(new, Canvas)
   return new
end

---Sets the Mouse position relative to the canvas.
---@overload fun(self:self, x:number,y:number): self
---@overload fun(self:self, pos:Vector2): self
---@param x number
---@param y number
---@param keep_auto boolean
---@generic self
---@param self self
---@return self
function Canvas:setMousePos(x,y,keep_auto)
   ---@cast self GNUI.Canvas
   local mpos = utils.figureOutVec2(x,y)
   local relative = mpos - self.MousePosition
   if relative.x ~= 0 or relative.y ~= 0 then   
      self.MousePosition = mpos
      
      local event = {}
      self.hasCustomCursorSetter = not keep_auto
      event.relative = relative
      event.pos = self.MousePosition
      self.INPUT:invoke(event)
      self.MOUSE_POSITION_CHANGED:invoke(event)
      self:updateHoveringChild()
   end
   return self
end

---@param e GNUI.any
local function getHoveringChild(e,position)
   position = position - e.ContainmentRect.xy
   if e.Visible and e.canCaptureCursor then
      for i = #e.Children, 1, -1 do
         local child = e.Children[i]
         if child.Visible and child.canCaptureCursor and child:isPositionInside(position) then
            return getHoveringChild(child,position)
         end
      end
   end
   return e
end

---@package
function Canvas:updateHoveringChild()
   local hovered_element = getHoveringChild(self,self.MousePosition)
   if hovered_element ~= self.HoveredElement then   
      if self.HoveredElement then
         self.HoveredElement:setIsCursorHovering(false)
      end
      if hovered_element then
         hovered_element:setIsCursorHovering(true)
      end
      self.HoveredElement = hovered_element
   end
   return self
end

---Returns which element the mouse cursor is on top of.
---@return GNUI.any
function Canvas:getHoveredElement()
   return self.HoveredElement
end

local function parseInputEventOnElement(element,event)
   local statuses = element.INPUT:invoke(event)
   for j = 1, #statuses, 1 do
      if statuses[j] and statuses[j][1] then 
         event.isHandled = true
         return true
      end
   end
end

---@param element GNUI.any
---@param event GNUI.InputEvent
local function parseInputEventToChildren(element,event,position)
   position = position - element.ContainmentRect.xy
   for i = #element.Children, 1, -1 do
      local child = element.Children[i]
      if child.Visible and child.canCaptureCursor and child:isPositionInside(position) then
         parseInputEventOnElement(child,event)
         return parseInputEventToChildren(child,event,position)
      end
   end
   return false
end



---Simulates a key event into the container.
---@param key Minecraft.keyCode
---@param status Event.Press.state
---@param ctrl boolean
---@param alt boolean
---@param shift boolean
---@param char string?
function Canvas:parseInputEvent(key,status,shift,ctrl,alt,char)
   ---@type GNUI.InputEvent
   local event = {
      char = char,
      key = key,
      isPressed = status ~= 0,
      status = status,
      ctrl = ctrl,
      alt = alt,
      shift = shift,
      isHandled = false,
   }
   local captured = false -- if somehow the canvas itself captured the inputs
   local statuses = self.INPUT:invoke(event)
   for i = 1, #statuses, 1 do
      if statuses[i] and statuses[i][1] then
         captured = true
         break
      end
   end
   if not captured then
      parseInputEventToChildren(self,event,self.MousePosition)
      if self.PressedElement and status == 0 and self.PressedElement ~= self.HoveredElement then -- QOL fix for buttons that have been unhovered but still pressed
         parseInputEventOnElement(self.PressedElement,event)
      end
   end
   if not event.isHandled then
      self.UNHANDLED_INPUT:invoke(event)
   end
   return self
end

---Sets whether the canvas should capture mouse movement.
---@param toggle boolean
---@generic self
---@param self self
---@return self
function Canvas:setCaptureMouseMovement(toggle)
---@cast self GNUI.Canvas
   self.captureCursorMovement = toggle
   return self
end

---Sets whether the canvas should capture inputs.
---@param toggle boolean
---@generic self
---@param self self
---@return self
function Canvas:setCaptureInputs(toggle)
---@cast self GNUI.Canvas
   self.captureInputs = toggle
   return self
end

return Canvas