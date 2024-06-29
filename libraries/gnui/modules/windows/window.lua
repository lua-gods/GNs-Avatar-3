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
local themes = require("libraries.gnui.modules.themes")

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
   new.type = "window"
   new.Title = ""
   
   themes.applyTheme(new,nil,"window")
   
   local label = gnui.newLabel()
   new.LabelTitle = label
   new:addChild(label)
   
   local closeButton = gnui_elements.newButton("window_close")
   new.CloseButton = closeButton
   new:addChild(closeButton)
   
   local maximizeButton = gnui_elements.newButton("window_maximize")
   new.MaximizeButton = maximizeButton
   new:addChild(maximizeButton)
   
   local minimizeButton = gnui_elements.newButton("window_minimize")
   new.MinimizeButton = minimizeButton
   new:addChild(minimizeButton)
   
   return new
end

return Window