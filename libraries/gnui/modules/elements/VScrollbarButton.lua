---@diagnostic disable: assign-type-mismatch
-- The Base class for all buttons. does not contain any visual elements.

local gnui = require("libraries.gnui")
local button = require("libraries.gnui.modules.elements.button")
local themes = require("libraries.gnui.modules.themes")
local eventLib = require("libraries.eventLib")


---@class GNUI.ScrollbarButton : GNUI.Button
---@field Scrollbar GNUI.Button
---@field Scroll number
---@field ScrollFrom number
---@field ScrollTo number
---@field ScrollSize number
---@field ON_SCROLL eventLib
---@field ScrollPercentage number
---@field package ScrollButtonRatio number
local VSB = {}
VSB.__index = function (t,i)
   return rawget(t,i) or VSB[i] or gnui.Container[i] or gnui.Element[i]
end
VSB.__type = "GNUI.Element.Container.Button.VScrollbarButton"

---Creates a new button.
---@return GNUI.ScrollbarButton
function VSB.new(variant,theme)
   variant = variant or "default"
   theme = theme or "default"
   
   ---@type GNUI.ScrollbarButton
   local new = button.new()
   local label = gnui.newLabel()
   new.label = label
   new:addChild(label)
   
   local scrollbar = button.new()
   scrollbar:setAnchor(0,0,1,0):setCanCaptureCursor(false)
   new:addChild(scrollbar)
   new.Scrollbar = scrollbar
   new.ScrollSize = 1
   new.Scroll = 0
   new.ScrollButtonRatio = 1
   new.ScrollFrom = 0
   new.ScrollTo = 1
   new.ON_SCROLL = eventLib.new()
   new.ScrollPercentage = 0
   setmetatable(new,VSB)
   themes.applyTheme(new,variant,theme)
   
   ---@param event GNUI.InputEventMouseMotion
   new.MOUSE_MOVED:register(function (event)
      if new.isPressed then
         new:setScroll(new.Scroll + (event.relative.y / (new:getSize().y * (1 - new.ScrollButtonRatio)) * new.ScrollSize))
      end
   end)
   ---@param event GNUI.InputEvent
   new.INPUT:register(function (event)
      if event.key == "key.mouse.scroll" then
         new:setScroll(new.Scroll - event.strength)
      end
   end)
   new.SIZE_CHANGED:register(function ()
      new:setRange(new.ScrollFrom,new.ScrollTo)
   end)
---@diagnostic disable-next-line: return-type-mismatch
   return new
end

---Sets the range of the scrollbar.
---@param from number
---@param to number
---@return GNUI.ScrollbarButton
function VSB:setRange(from,to)
   self.ScrollFrom = from
   self.ScrollTo = math.max(from+1,to)
   self.ScrollSize = self.ScrollTo-self.ScrollFrom
   self.ScrollButtonRatio = 1/math.min(self.ScrollSize,8)
   self:setScroll(self.Scroll)
   return self
end

function VSB:setScroll(value)
   self.Scroll = math.clamp(value,self.ScrollFrom,self.ScrollTo)
   self.ScrollPercentage = math.clamp(math.map(self.Scroll,self.ScrollFrom,self.ScrollTo,0,1),0,1)
   self.ON_SCROLL:invoke(self.Scroll)
   self:update()
end

function VSB:_update()
   local sp = self.ScrollPercentage
   self.Scrollbar:setAnchor(0,sp-self.ScrollButtonRatio*sp,1,sp+self.ScrollButtonRatio*(1-sp))
   gnui.Container._update(self)
end

return VSB