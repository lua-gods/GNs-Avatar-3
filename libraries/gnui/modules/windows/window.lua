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

local MINIMUM_SIZE = vec(32,16)
local BDS = 3 -- Border Drag Size

local gnui = require("libraries.gnui")
local gnui_elements = require("libraries.gnui.modules.elements")
local themes = require("libraries.gnui.modules.themes")

---@param container GNUI.container
---@param window GNUI.window
---@param fun function
local function applyDrag(container,window,fun)
   container.INPUT:register(function (event)
      if event.key == "key.mouse.left"then
         if event.isPressed then
            window.Canvas.MOUSE_POSITION_CHANGED:register(function (mouse_event)
               fun(mouse_event)
            end,"window_drag"..window.id)
         else window.Canvas.MOUSE_POSITION_CHANGED:remove("window_drag"..window.id) end
      end
   end)
end

---@class GNUI.window : GNUI.container
---@field Theme GNUI.theme
---@field LabelTitle GNUI.label
---@field Title string
---@field Titlebar GNUI.container
---@field CloseButton GNUI.button
---@field MinimizeButton GNUI.button
---@field MaximizeButton GNUI.button
---@field Icon Ninepatch
---@field isActive boolean
---@field isMaximized boolean
---@field isGrabbed boolean
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
   
   local label = gnui.newLabel()
   new.LabelTitle = label
   new:addChild(label)
   
   local titleBar = gnui.newContainer()
   new.Titlebar = titleBar
   new:addChild(titleBar)
   
   local closeButton = gnui_elements.newButton("nothing")
   new.CloseButton = closeButton
   new:addChild(closeButton)
   
   local maximizeButton = gnui_elements.newButton("nothing")
   new.MaximizeButton = maximizeButton
   new:addChild(maximizeButton)
   
   local minimizeButton = gnui_elements.newButton("nothing")
   new.MinimizeButton = minimizeButton
   new:addChild(minimizeButton)
   
   setmetatable(new,Window)
   themes.applyTheme(new)
   
   local leftBorderDrag = gnui.newContainer()
   :setAnchor(0,0,0,1):setDimensions(0,BDS,BDS,-BDS)
   themes.applyTheme(leftBorderDrag,"window_border_drag")
   new:addChild(leftBorderDrag)
   applyDrag(leftBorderDrag,new,function (mouse_event)
      new:setDimensions(math.min(new.Dimensions.x + mouse_event.relative.x,new.Dimensions.z-MINIMUM_SIZE.x),new.Dimensions.y,new.Dimensions.z,new.Dimensions.w)
   end)
   
   local rightBorderDrag = gnui.newContainer()
   :setAnchor(1,0,1,1):setDimensions(-BDS,BDS,0,-BDS)
   themes.applyTheme(rightBorderDrag,"window_border_drag")
   new:addChild(rightBorderDrag)
   applyDrag(rightBorderDrag,new,function (mouse_event)
      new:setDimensions(new.Dimensions.x,new.Dimensions.y,math.max(new.Dimensions.z + mouse_event.relative.x,new.Dimensions.x+MINIMUM_SIZE.x),new.Dimensions.w)
   end)
   
   local topBorderDrag = gnui.newContainer()
   :setAnchor(0,0,1,0):setDimensions(BDS,0,-BDS,BDS)
   themes.applyTheme(topBorderDrag,"window_border_drag")
   new:addChild(topBorderDrag)
   applyDrag(topBorderDrag,new,function (mouse_event)
      new:setDimensions(new.Dimensions.x,math.min(new.Dimensions.y + mouse_event.relative.y,new.Dimensions.w-MINIMUM_SIZE.y),new.Dimensions.z,new.Dimensions.w)
   end)
   
   local bottomBorderDrag = gnui.newContainer()
   :setAnchor(0,1,1,1):setDimensions(BDS,-BDS,-BDS,0)
   themes.applyTheme(bottomBorderDrag,"window_border_drag")
   new:addChild(bottomBorderDrag)
   applyDrag(bottomBorderDrag,new,function (mouse_event)
      new:setDimensions(new.Dimensions.x,new.Dimensions.y,new.Dimensions.z,math.max(new.Dimensions.w + mouse_event.relative.y,new.Dimensions.y+MINIMUM_SIZE.y))
   end)
   
   local topRightCornerDrag = gnui.newContainer()
   :setAnchor(1,0):setDimensions(-BDS,0,0,BDS)
   themes.applyTheme(topRightCornerDrag,"window_border_drag")
   new:addChild(topRightCornerDrag)
   applyDrag(topRightCornerDrag,new,function (mouse_event)
      new:setDimensions(
         new.Dimensions.x,
         math.min(new.Dimensions.y + mouse_event.relative.y,new.Dimensions.w-MINIMUM_SIZE.y),
         math.max(new.Dimensions.z + mouse_event.relative.x,new.Dimensions.x-MINIMUM_SIZE.x),
         new.Dimensions.w)
   end)
   
   local bottomRightCornerDrag = gnui.newContainer()
   :setAnchor(1,1):setDimensions(-BDS,-BDS,0,0)
   themes.applyTheme(bottomRightCornerDrag,"window_border_drag")
   new:addChild(bottomRightCornerDrag)
   applyDrag(bottomRightCornerDrag,new,function (mouse_event)
      new:setDimensions(
         new.Dimensions.x,
         new.Dimensions.y,
         math.max(new.Dimensions.z + mouse_event.relative.x,new.Dimensions.x-MINIMUM_SIZE.x),
         math.max(new.Dimensions.w + mouse_event.relative.y,new.Dimensions.y-MINIMUM_SIZE.y))
   end)
   
   local bottomLeftCornerDrag = gnui.newContainer()
   :setAnchor(0,1):setDimensions(0,-BDS,BDS,0)
   themes.applyTheme(bottomLeftCornerDrag,"window_border_drag")
   new:addChild(bottomLeftCornerDrag)
   applyDrag(bottomLeftCornerDrag,new,function (mouse_event)
      new:setDimensions(
         math.min(new.Dimensions.x + mouse_event.relative.x,new.Dimensions.z-MINIMUM_SIZE.x),
         new.Dimensions.y,
         new.Dimensions.z,
         math.max(new.Dimensions.w + mouse_event.relative.y,new.Dimensions.y-MINIMUM_SIZE.y))
   end)
   
   local topLeftCornerDrag = gnui.newContainer()
   :setAnchor(0,0):setDimensions(0,0,BDS,BDS)
   themes.applyTheme(topLeftCornerDrag,"window_border_drag")
   new:addChild(topLeftCornerDrag)
   applyDrag(topLeftCornerDrag,new,function (mouse_event)
      new:setDimensions(
         math.min(new.Dimensions.x + mouse_event.relative.x,new.Dimensions.z-MINIMUM_SIZE.x),
         math.min(new.Dimensions.y + mouse_event.relative.y,new.Dimensions.w-MINIMUM_SIZE.y),
         new.Dimensions.z,
         new.Dimensions.w)
   end)
   
   new.isGrabbed = false
   local grab_canvas ---@type GNUI.canvas
   ---@param event GNUI.InputEvent
   new.Titlebar.INPUT:register(function (event)
      if event.key == "key.mouse.left"then
         new.isGrabbed = event.isPressed
         if event.isPressed then
            grab_canvas = new.Canvas
            ---@param mouse_event GNUI.InputEventMouseMotion
            new.Canvas.MOUSE_POSITION_CHANGED:register(function (mouse_event)
               new:setPos(new.Dimensions.xy+mouse_event.relative)
            end,"window_drag"..new.id)
         else
            if grab_canvas then
               grab_canvas.MOUSE_POSITION_CHANGED:remove("window_drag"..new.id)
            end
            
            -- convert dimensions to anchor
            local shift = (new.Dimensions.zw - new.Dimensions.xy) * (vec(1-new.Anchor.x,new.Anchor.y)) ---@type Vector2
            local pos = new.Dimensions.xy + new.Parent:UVtoXY(new.Anchor.xy)
            local pos_uv = new.Parent:XYtoUV(pos + shift)
            new:setAnchor(pos_uv.x,pos_uv.y)
            new:setPos(-shift.x,-shift.y)
         end
      end
      return true
   end)
   
   return new
end

return Window