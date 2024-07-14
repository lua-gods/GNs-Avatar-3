--[[______   __
  / ____/ | / / By: GNamimates
 / / __/  |/ / GNUI v2.0.0
/ /_/ / /|  / A high level UI library for figura.
\____/_/ |_/ Stable Release: https://github.com/lua-gods/GNUI, Unstable Pre-release: https://github.com/lua-gods/GNs-Avatar-3/blob/main/libraries/gnui.lua]]

--[[ NOTES
Everything is in one file to make sure it is possible to load this script from a config file, 
allowing me to put as much as I want without worrying about storage space.
]]

---@class GNUI
local api = {}

---@alias GNUI.any GNUI.element|GNUI.Container|GNUI.label|GNUI.anchorPoint|GNUI.canvas

local utils = require("libraries.gnui.utils")
local label = require("libraries.gnui.primitives.label")
local sprite = require("libraries.gnui.spriteLib")
local canvas = require("libraries.gnui.primitives.canvas")
local element = require("libraries.gnui.primitives.element")
local container = require("libraries.gnui.primitives.container")
local anchor = require("libraries.gnui.primitives.anchor")

api.newPointAnchor = function ()return anchor.new()end
api.newContainer = function ()return container.new() end
api.newCanvas = function ()return canvas.new() end
api.newLabel = function ()return label.new() end

---@param texture Texture?
---@return Sprite
api.newSprite = function (texture)
  return sprite.new()
end

api.utils = utils

api.Container = container
api.Anchor = anchor
api.Element = element
api.Canvas = canvas
api.Sprite = sprite
api.Label = label

local screenCanvas
---Gets a canvas for the screen. Quick startup for putting UI elements onto the screen.
---@return GNUI.canvas
function api.getScreenCanvas()
  if not screenCanvas then
    screenCanvas = api.newCanvas()
    models:addChild(screenCanvas.ModelPart)
    screenCanvas.ModelPart:setParentType("HUD")
  
    local lastWindowSize = vec(0,0)
    events.WORLD_RENDER:register(function (delta)
      local windowSize = client:getScaledWindowSize()
      
      if windowSize.x ~= lastWindowSize.x
      or windowSize.y ~= lastWindowSize.y then
        lastWindowSize = windowSize
        screenCanvas:setDimensions(0,0,windowSize.x,windowSize.y)
      end
    end)
    screenCanvas:setDimensions(0,0,client:getScaledWindowSize().x,client:getScaledWindowSize().y)
  end
  return screenCanvas
end

---@param sound Minecraft.soundID
---@param pitch number
---@param volume number
function api.playSound(sound,pitch,volume)
  sounds[sound]:pos(client:getCameraPos():add(client:getCameraDir())):pitch(pitch or 1):volume(volume or 1):attenuation(9999):play()
end

return api