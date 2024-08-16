local GNUI = require("GNUI.main")
local GNUIElements = require("GNUI.modules.elements")
local screen = GNUI.getScreenCanvas()

local ICON_SIZE = 12

local Statusbar = GNUIElements.newStack()
:setAnchor(0.5,0.5)
Statusbar:setIsHorizontal(true)
:setSize(ICON_SIZE,ICON_SIZE)
screen:addChild(Statusbar)
local hoverLabel = GNUI.newLabel()
hoverLabel
:setAnchor(0.5,0.5)
:setDimensions(-60,-10,60,-10)
:setAlign(0.5)
:setTextEffect("OUTLINE")
screen:addChild(hoverLabel)

local api = {}

local function newButton(name)
   Statusbar:setPos(ICON_SIZE * -0.5 * (#Statusbar.Children+1),0)
   local button = GNUIElements.newSingleSpriteButton()
   button.MOUSE_PRESSENCE_CHANGED:register(function (hovered)
      if hovered then
         hoverLabel:setText(name)
      else
         hoverLabel:setText("")
      end
   end)
   button:setCustomMinimumSize(ICON_SIZE,ICON_SIZE)
   Statusbar:addChild(button)
   return button
end

--- Registers a new button for the statusbar.
---@param icon Texture
---@param x number?
---@param y number?
---@param w number?
---@param h number?
---@return GNUI.SingleSpriteButton
function api.newButtonTexture(name,icon,x,y,w,h)
   local button = newButton(name)
   button:setSprite(GNUI.newSprite():setTexture(icon):setUV(x,y,w,h))
   return button
end

---Registers a new button for the statusbar.
---@param sprite Sprite
---@return GNUI.SingleSpriteButton
function api.newButtonSprite(name,sprite)
   local button = newButton(name):setSprite(sprite)
   return button
end

return api