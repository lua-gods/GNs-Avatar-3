local keybind = keybinds:fromVanilla("figura.config.action_wheel_button")
local esc = keybinds:newKeybind("Escape","key.keyboard.escape",true)
local GNUI = require("GNUI.main")
local statusbar = require("scriptHost.statusbar")
local screen = GNUI:getScreenCanvas()

local unlocked = false

statusbar.container:setVisible(false)

local function toggle(state)
  host:setUnlockCursor(state)
  renderer:setRenderCrosshair(not state)
  statusbar.container:setVisible(state)
end

local pressTime
keybind:onPress(function ()
  pressTime = client:getSystemTime()
  unlocked = not unlocked
  toggle(unlocked)
  return true
end):onRelease(function ()
  if client:getSystemTime() - pressTime > 200 then --ms that determins if the unlock of the cursor should be a toggle or not
   unlocked = false
   toggle(false)
  end
end)

esc:onPress(function ()
  if unlocked then
   unlocked = false
   toggle(false)
   return true
  end
end)

events.MOUSE_SCROLL:register(function (dir) 
  if unlocked then
   return true
  end
end)