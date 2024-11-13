local pages = require"libraries.pages"

local key = keybinds:fromVanilla("figura.config.action_wheel_button")

local pressTime = 0
local unlocked = false

---@param isUnlocked boolean
local function cursor(isUnlocked)
  renderer:setRenderCrosshair(not isUnlocked)
  host.unlockCursor = isUnlocked
  unlocked = isUnlocked
  pages.setPage(isUnlocked and "home" or nil)
end

key.press = function ()
  pressTime = client:getSystemTime()
  cursor(not unlocked)
  
  return true
end
key.release = function ()
  local releaseTime = client:getSystemTime()
  if releaseTime - pressTime > 300 then
    cursor(not unlocked)
  end
end