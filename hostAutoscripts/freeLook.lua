local tween = require "libraries.tween"

local SENSITIVITY = 0.1

local keybind = keybinds:newKeybind("freelook","key.keyboard.left.alt")
local offset = vectors.vec2()
local zoom = 1
local active = false

local function release()
   active = false
   zoom = 1
   renderer:setFOV()
   local from = offset:copy()
   tween.tweenFunction(from,vectors.vec2(0,0),0.2,"inOutSine",function (value, transition)
      offset = value
      renderer:offsetCameraRot(offset.y,offset.x)
   end)
end


keybind.press = function ()
	active = true
end

keybind.release = function ()
	if active then release() end
end

events.MOUSE_MOVE:register(function (x, y)
   if active then
      offset.x = offset.x + x * SENSITIVITY * ((zoom - 1) * math.pow(1 - math.abs(client:getCameraDir().y),zoom / 2) + 1) -- reduce the sensitivity based on the X rotation of the camera
      offset.y = offset.y + y * SENSITIVITY * zoom
      renderer:offsetCameraRot(offset.y,offset.x) -- mineccraft flipped them
      return true
   elseif active then
      release()
      return true
   end
end)

events.MOUSE_SCROLL:register(function (dir)
   if active then
      zoom = zoom - (dir * 0.1 * zoom)
      renderer:setFOV(zoom)
		return true
   end
end)