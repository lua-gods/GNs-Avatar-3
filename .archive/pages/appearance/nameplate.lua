local Dialog = require"lib.dialog"
local page = Dialog.newPage({
  name = "Nameplate",
  color="#e3c58a",
  positioning = "HOTBAR RIGHT",
})

local GNUI = require"lib.GNUI.main"
local Button = require"lib.GNUI.element.button"

page:newReturnButton()

return page