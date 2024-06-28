
local gnui = require("libraries.gnui")

---@class GNUI.window : GNUI.container
---@field Theme GNUI.theme
---@field LabelTitle GNUI.label
---@field Title string
---@field CloseButton GNUI.button
---@field MinimizeButton GNUI.button
---@field MaximizeButton GNUI.button
---@field Icon Ninepatch
---@field isActive boolean
---@field isMaximized boolean
local Window = {}
Window.__index = function (t,i)
   return rawget(t,i) or Window[i] or gnui.metatables.container[i] or gnui.metatables.element[i]
end
Window.__type = "GNUI.element.container.window"

