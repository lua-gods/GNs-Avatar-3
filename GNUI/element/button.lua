--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / The Button Class.
/ /_/ / /|  / The base class for all clickable buttons.
\____/_/ |_/ Source: link]]
---@diagnostic disable: assign-type-mismatch
local Box = require"GNUI.primitives.box"
local eventLib = require"libraries.eventLib"
local Theme = require"GNUI.theme"

---@class GNUI.Button : GNUI.Box
---@field PRESSED EventLib
---@field BUTTON_DOWN EventLib
---@field BUTTON_UP EventLib
---@field keybind GNUI.keyCode
local Button = {}
Button.__index = function (t,i) return rawget(t,i) or Button[i] or Box[i] end
Button.__type = "GNUI.Button"


---@param parent GNUI.Box?
---@param variant string?
---@return GNUI.Button
function Button.new(parent,variant)
  
  ---@type GNUI.Button
  local new = setmetatable(Box.new(parent),Button)
  new.PRESSED = eventLib.new()
  new.BUTTON_DOWN = eventLib.new()
  new.BUTTON_UP = eventLib.new()
  new.keybind = "key.mouse.left"
  
  Theme.style(new,variant)
  return new
end

return Button