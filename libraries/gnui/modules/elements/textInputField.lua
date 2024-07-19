---@diagnostic disable: assign-type-mismatch
-- Serves as a way to create buttons with text within them

local gnui = require("libraries.gnui")
local themes = require("libraries.gnui.modules.themes")
local Btn = require("libraries.gnui.modules.elements.button")
local container = require("libraries.gnui.primitives.container")

local is_typing = false -- a global that stops the keyboard from interacting with the world temporarily
local chat_text = ""
local function setIsTyping(toggle)
   if toggle ~= is_typing then
      is_typing = toggle
      if toggle then
         chat_text = host:getChatText()
         events.WORLD_RENDER:register(function ()
            host:setChatText("")
         end,"gnui.textInputFieldStopper")
         events.MOUSE_PRESS:register(function ()
            return true
         end,"gnui.textInputFieldStopper")
      else
         if chat_text then
            host:setChatText(chat_text)
            events.WORLD_RENDER:remove("gnui.textInputFieldStopper")
            events.MOUSE_PRESS:remove("gnui.textInputFieldStopper")
         end
      end
   end
end

events.KEY_PRESS:register(function (key,state) 
   if is_typing then
      return true
   end
end)

---@class GNUI.TextInputField : GNUI.Button
---@field ConfirmedText string
---@field PotentialText string
---@field PlaceholderText string
---@field editing boolean
---@field Label GNUI.Label
---@field BarCaret GNUI.Label
---@field CursorPos integer
---@field CursorSize integer
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
         if new.editing and event.key and event.key:find("^key.mouse.") and not event.isPressed then
            new:setConfirmedText(new.PotentialText)
         end
         if new.editing and event.isPressed then -- typing
            if event.ctrl then
               if event.key == "key.keyboard.v" then
                  local clipboard = host:getClipboard()
                  new.PotentialText = new.PotentialText..clipboard
               elseif event.key == "key.keyboard.c" then
                  host:setClipboard(new.PotentialText)
               elseif event.key == "key.keyboard.x" then
                  host:setClipboard(new.PotentialText)
                  new.PotentialText = ""
               elseif event.key == "key.keyboard.backspace" then
                  local to = new.PotentialText:find("[^%s]*$")
                  if to then
                     new.PotentialText = new.PotentialText:sub(1,math.min(to-1,#new.PotentialText-1))
                  end
               end
            else
               if event.key:find"enter$" or event.key == "key.keyboard.escape" then
                  new:setConfirmedText(new.PotentialText)
               elseif event.key == "key.keyboard.backspace" then
                  new.PotentialText = new.PotentialText:sub(1,-2)
               elseif event.char then
                  new.PotentialText = new.PotentialText..event.char
               end
            end
            new:update()
            return true
         end
      end,id)
   end
   
   new.PRESSED:register(function () 
      new.editing = true
      new.PotentialText = new.ConfirmedText
      setIsTyping(true)
      new:updateTheming()
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

function TIB:_update()
   if self.editing then
      self.Label:setText(self.PotentialText)
      self.BarCaret:setVisible(true)
   else
      self.Label:setText(self.ConfirmedText)
      self.BarCaret:setVisible(false)
   end
   container._update(self)
   return self
end

---Sets the confirmed text of this label, meaning editing will be forced to stop.
---@param text string|table
---@generic self
---@param self self
---@return self
function TIB:setConfirmedText(text)
   ---@cast self GNUI.TextInputField
   self.ConfirmedText = text
   self.PotentialText = ""
   setIsTyping(false)
   self.editing = false
   self:updateTheming()
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
      setIsTyping(true)
      self:updateTheming()
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