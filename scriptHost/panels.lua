local GNUI = require"GNUI.main"
local Theme = require"GNUI.theme"
local Button = require"GNUI.element.button"
local eventLib = require"libraries.eventLib"
local screen = GNUI.getScreenCanvas()



---@class GNUI.Panel.Page
---@field name string?
---@field content GNUI.Panel.any[]
local Page = {}
Page.__index = Page

---@alias GNUI.Panel.any GNUI.Panel.Button|GNUI.Panel.Slider

---@class GNUI.Panel.Button
---@field text string
---@field onClick fun(self: GNUI.Panel.Button)

---@class GNUI.Panel.Slider
---@field text string
---@field min number
---@field max number
---@field step number
---@field value number
---@field onChange fun(value: number, self: GNUI.Panel.Slider)
---@field onClick fun(self: GNUI.Panel.Button)


---@class GNUI.Panel
---@field page GNUI.Panel.Page
---@field box GNUI.Box
local Panels = {}


---@param parent GNUI.any
function Panels.new(parent)
  local self = {
    box = GNUI.newBox(parent)
  }
  setmetatable(self,Panels)
  return self
end


return Panels