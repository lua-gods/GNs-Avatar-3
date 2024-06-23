---@diagnostic disable: assign-type-mismatch

local gnui = require("libraries.gnui")

local theme = require("libraries.gnui_extras.theme")

local eventLib = require("libraries.eventLib")


---@class GNUI.button : GNUI.container
---@field Pressed boolean
---@field text string
---@field Theme GNUI.theme
local Button = {}
Button.__index = function (t,i)
   return rawget(t,i) or gnui.metatables.container[i] or gnui.metatables.element[i]
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
   
   theme.button.variants[variant](new,gnui.newLabel())
   
   setmetatable(new,Button)
   return new
end

return Button