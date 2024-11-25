local Pages = require"lib.pages"

local key = keybinds:fromVanilla("figura.config.action_wheel_button")

local pressTime = 0

Pages.PAGE_CHANGED:register(function (currentPage)
  local isDefault = Pages.currentPage ~= "default"
  renderer:setRenderCrosshair(not isDefault)
  host.unlockCursor = isDefault
end)

local function togglePage()
  Pages.setPage(Pages.currentPage == "default" and "home" or "default")
end

key.press = function ()
  pressTime = client:getSystemTime()
  togglePage()
  return true
end
key.release = function ()
  local releaseTime = client:getSystemTime()
  if releaseTime - pressTime > 300 then
    togglePage()
  end
end