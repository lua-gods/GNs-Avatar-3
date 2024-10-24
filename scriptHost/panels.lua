
local GNUI = require"GNUI.main"
local Theme = require"GNUI.theme"
local Button = require"GNUI.element.button"
local screen = GNUI.getScreenCanvas()

local Dialog = require"libraries.dialog"
local panels = Dialog.newDialog(screen,"HOTBAR RIGHT")

local homePage = require"pages.home"

panels:setPage(homePage)

local wasUnlocked = false
events.WORLD_RENDER:register(function ()
  local isUnlocked = host:isCursorUnlocked()
  if wasUnlocked ~= isUnlocked then
    wasUnlocked = isUnlocked
    panels.box:setVisible(isUnlocked or panels.page ~= homePage)
  end
end)

panels.box:setVisible(false)