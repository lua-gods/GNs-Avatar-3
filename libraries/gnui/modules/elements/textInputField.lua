---@diagnostic disable: assign-type-mismatch
-- Serves as a way to create buttons with text within them

local gnui = require("libraries.gnui")
local themes = require("libraries.gnui.modules.themes")
local Btn = require("libraries.gnui.modules.elements.button")

---@class GNUI.TextInputField : GNUI.Button
---@field ConfirmedText string
---@field PotentialText string
---@field PlaceholderText string
---@field editing boolean
---@field Label GNUI.Label
---@field BarCaret GNUI.Label
local TIB = {}
TIB.__index = function (t,i)
   return rawget(t,i) or TIB[i] or Btn[i] or gnui.Container[i] or gnui.Element[i]
end
TIB.__type = "GNUI.Element.Container.Button.TextInputButton"

---Creates a new button.
---@return GNUI.TextInputField
function TIB.new(variant,theme)
   variant = variant or "default"
   theme = theme or "default"
   ---@type GNUI.TextInputField
   local new = Btn.new()
   local label = gnui.newLabel():setAnchor(0,0,1,1):setAlign(0,0.5):setCanCaptureCursor(false)
   new.Label = label
   new.ConfirmedText = ""
   new.PotentialText = ""
   new.BarCaret = gnui.newLabel():setText("|"):setAnchor(0,0,1,1):setAlign(0,0.5):setCanCaptureCursor(false)
   new.PlaceholderText = ""
   new.editing = false
   
   label:addChild(new.BarCaret)
   new:addChild(label)
   
   local id = "textInputButton"..new.id
   
   local inputCapture = function (cnew)
      ---@param event GNUI.InputEvent
      cnew.INPUT:register(function (event)
         --print(new.editing, event.key, event.isPressed)
         if new.editing and event.key and event.key:find("^key.mouse.") and event.isPressed then
            new.editing = false
            new.MOUSE_PRESSENCE_CHANGED:invoke(new.isCursorHovering,new.isPressed) -- TODO: janky fix, replace with an API call
            new:update()
         end
         if new.editing then
            if event.char then
               new.PotentialText = new.PotentialText..event.char
            end
            return true
         end
      end,id)
   end
   
   new.PRESSED:register(function () 
      new.editing = true
      new.MOUSE_PRESSENCE_CHANGED:invoke(new.isCursorHovering,new.isPressed) -- TODO: janky fix, replace with an API call
      new:update()
   end)
   
   ---@param cnew GNUI.Canvas
   ---@param cold GNUI.Canvas
   new.CANVAS_CHANGED:register(function (cnew,cold)
      if cold then cold.INPUT:remove(id) end
      if cnew then inputCapture(cnew) else new.editing = false new:update() end
   end)
   
   new:addChild(label)
   setmetatable(new,TIB)
   themes.applyTheme(new,variant,theme)
   return new
end

---Sets the confirmed text of this label, meaning editing will be forced to stop.
---@param text string|table
---@generic self
---@param self self
---@return self
function TIB:setConfirmedText(text)
   ---@cast self GNUI.TextInputField
   self.ConfirmedText = text
   self.editing = false
   self:update()
   return self
end

---Sets the potential text of this label, only works when the input field is being edited.
---@param text string|table
---@generic self
---@param self self
---@return self
function TIB:setPotentialText(text)
   ---@cast self GNUI.TextInputField
   if self.editing then
      self.PotentialText = text
      self:update()
   end
   return self
end

---Gets the text of this label
---@return string|table
function TIB:getText()
   return self.Label.Text
end

return TIB