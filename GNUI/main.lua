--[[______  __
  / ____/ | / / By: GNamimates
 / / __/  |/ / GNUI v2.0.0
/ /_/ / /|  / A high level UI library for figura.
\____/_/ |_/ Stable Release: https://github.com/lua-gods/GNUI, Unstable Pre-release: https://github.com/lua-gods/GNs-Avatar-3/blob/main/libraries/gnui.lua]]

--[[ NOTES
Everything is in one file to make sure it is possible to load this script from a config file, 
allowing me to put as much as I want without worrying about storage space.
]]

local cfg = require("GNUI.config")
---@class GNUI

local api = {path = cfg.path}
---@alias GNUI.any GNUI.Box|GNUI.Box|GNUI.Canvas

local u = require("GNUI.utils")
local s = require("GNUI.ninepatch")
local ca = require("GNUI.primitives.canvas")
local co = require("GNUI.primitives.box")


---Creates a new Box.  
---A canvas can be given as a parameter to automatically add child it to that
---@param canvas GNUI.Canvas?
---@return GNUI.Box
api.newBox = function (canvas) 
  local new = co.new()
  if canvas then canvas:addChild(new) end
  return new
end


---@param autoInputs boolean # true when the canvas should capture the inputs from the screen.
---@return unknown
api.newCanvas = function (autoInputs)return ca.new(autoInputs) end


---@param texture Texture?
---@param borderTop number?
---@param borderRight number?
---@param borderBottom number?
---@param borderLeft number?
---@param UVx1 number?
---@param UVy1 number?
---@param UVx2 number?
---@param UVy2 number?
---@return Ninepatch
api.newNineslice = function (texture,borderTop,borderRight,borderBottom,borderLeft,UVx1,UVy1,UVx2,UVy2)
  local new = s.new()
  if texture then new:setTexture(texture) end
  if borderTop then new:setBorderTop(borderTop) end
  if borderRight then new:setBorderRight(borderRight) end
  if borderBottom then new:setBorderBottom(borderBottom) end
  if borderLeft then new:setBorderLeft(borderLeft) end
  if UVx1 and UVy1 and UVx2 and UVy2 then new:setUV(UVx1,UVy1,UVx2,UVy2) end
  return new
end


local screenCanvas
---Gets a canvas for the screen. Quick startup for putting UI elements onto the screen.
---@return GNUI.Canvas
function api.getScreenCanvas()
  if not screenCanvas then
   screenCanvas = api.newCanvas(true)
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
---@param pitch number?
---@param volume number?
function api.playSound(sound,pitch,volume)
  sounds[sound]:pos(client:getCameraPos():add(client:getCameraDir())):pitch(pitch or 1):volume(volume or 1):attenuation(9999):play()
end

return api