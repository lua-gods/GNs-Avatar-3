--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / Optional Module for GNUI that adds Desktop windows into GNUI.
/ /_/ / /|  / 
\____/_/ |_/ link
DEPENDENCIES
- GNUI
- GNUI Elements Module
]]
---@diagnostic disable: assign-type-mismatch

local gnui = require("libraries.gnui")
local gnui_elements = require("libraries.gnui.modules.elements")

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
   return rawget(t,i) or Window[i] or gnui.container[i] or gnui.element[i]
end
Window.__type = "GNUI.element.container.window"
function Window.new()
   ---@type GNUI.window
   local new = gnui.newContainer()
   new._parent_class = Window
   new.type = "window"
   new.Title = ""
   
   local label = gnui.newLabel()
   new.LabelTitle = label
   new:addChild(label)
   
   local closeButton = gnui_elements.newButton("nothing")
   new.CloseButton = closeButton
   new:addChild(closeButton)
   return new
end

return Window