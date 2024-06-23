---@diagnostic disable: assign-type-mismatch

local gnui = require("libraries.gnui")

local theme = require("libraries.gnui_extras.theme")

local eventLib = require("libraries.eventLib")


---@class GNUI.button : GNUI.container
---@field Pressed boolean
---@field label GNUI.label
---@field Theme GNUI.theme
local Button = {}
Button.__index = function (t,i)
   return rawget(t,i) or Button[i] or gnui.metatables.container[i] or gnui.metatables.element[i]
end
Button.__type = "GNUI.element.container.button"

---Creates a new button.
---@return GNUI.button
function Button.new(variant)
   variant = variant or "default"
   ---@type GNUI.button
   local new = gnui.newContainer()
   new.Text = ""
   new.Pressed = false
   new.PRESSED = eventLib.new()
   new.RELEASED = eventLib.new()
   new.Theme = theme
   local label = gnui.newLabel()
   theme.button.variants[variant](new,label)
   new.label = label
   setmetatable(new,Button)
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