local Dialog = require"libraries.dialog"
local page = Dialog.newPage({
  name = "Nameplate",
  color="#e3c58a",
  positioning = "HOTBAR RIGHT",
})

local GNUI = require"GNUI.main"
local Button = require"GNUI.element.button"

page:newReturnButton()

return page