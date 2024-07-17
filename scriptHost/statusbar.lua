local GNUI = require("libraries.gnui")
local GNUIElements = require("libraries.gnui.modules.elements")
local screen = GNUI.getScreenCanvas()

local statusbar = GNUIElements.newStack():setIsHorizontal(true)
:setPos(2,2)
:setSize(8,8)
--:setPos(2,-23)
screen:addChild(statusbar)

local api = {}

local function newButton()
   local button = GNUIElements.newSingleSpriteButton()
   button:setCustomMinimumSize(8,8)
   statusbar:addChild(button)
   return button
end

--- Registers a new button for the statusbar.
---@param icon Texture
---@param x number?
---@param y number?
---@param w number?
---@param h number?
---@return GNUI.SingleSpriteButton
function api.newButtonTexture(icon,x,y,w,h)
   local button = newButton()
   button:setSprite(GNUI.newSprite():setTexture(icon):setUV(x,y,w,h))
   return button
end

---Registers a new button for the statusbar.
---@param sprite Sprite
---@return GNUI.SingleSpriteButton
function api.newButtonSprite(sprite)
   local button = newButton():setSprite(sprite)
   return button
end

return api