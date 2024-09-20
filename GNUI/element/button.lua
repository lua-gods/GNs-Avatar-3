---@diagnostic disable: assign-type-mismatch
local Box = require"GNUI.primitives.box"
local eventLib = require"libraries.eventLib"
local theme = require"GNUI.theme"

---@class GNUI.Button : GNUI.Box
---@field PRESSED EventLib
---@field BUTTON_DOWN EventLib
---@field BUTTON_UP EventLib
---@field keybind GNUI.keyCode
local Button = {}
Button.__index = function (t,i) return rawget(t,i) or Button[i] or Box[i] end
Button.__type = "GNUI.Button"


---@return GNUI.Button
function Button.new()
  ---@type GNUI.Button
  local new = setmetatable(Box.new(),Button)
  new.PRESSED = eventLib.new()
  new.BUTTON_DOWN = eventLib.new()
  new.BUTTON_UP = eventLib.new()
  new.keybind = "key.mouse.left"
  return new
end

return Button