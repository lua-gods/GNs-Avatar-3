---@diagnostic disable: assign-type-mismatch

local gnui = require("libraries.gnui")
local themes = require("libraries.gnui.modules.themes")
local eventLib = require("libraries.eventLib")


---@class GNUI.button : GNUI.container
---@field Pressed boolean
---@field label GNUI.label
local Button = {}
Button.__index = function (t,i)
   return rawget(t,i) or Button[i] or gnui.container[i] or gnui.element[i]
end
Button.__type = "GNUI.element.container.button"

---Creates a new button.
---@return GNUI.button
function Button.new(variant,theme)
   variant = variant or "default"
   theme = theme or "default"
   ---@type GNUI.button
   local new = gnui.newContainer()
   new.Text = ""
   new.PRESSED = eventLib.new()
   new.BUTTON_DOWN = eventLib.new()
   new.BUTTON_UP = eventLib.new()
   local label = gnui.newLabel()
   new.label = label
   new:addChild(label)
   setmetatable(new,Button)
   themes.applyTheme(new,theme,variant)
   new.cache.was_pressed = false
   ---@param event GNUI.InputEvent
   new.INPUT:register(function (event)
      if event.key == "key.mouse.left" then
         if event.isPressed then new.BUTTON_DOWN:invoke()
         else new.BUTTON_UP:invoke() gnui:playSound("minecraft:ui.button.click",1,1) end
         if new.isCursorHovering then
            if not event.isPressed and new.cache.was_pressed then
               new.PRESSED:invoke()
            end
            new.cache.was_pressed = event.isPressed
         end
      end
   end,"_button")
   return new
end

---Sets the text of this label, accepts raw json as a table
---@param text string|table
---@generic self
---@param self self
---@return self
function Button:setText(text)
   ---@cast self GNUI.button
   self.label:setText(text)
   return self
end

---Gets the text of this label
---@return string|table
function Button:getText()
   return self.label.Text
end

return Button