local Dialog = require"libraries.dialog"
local page = Dialog.newPage({
  name = "Utilities",
  color="#73c1de",
  positioning = "HOTBAR RIGHT",
})

local GNUI = require"GNUI.main"
local Button = require"GNUI.element.button"

page:newReturnButton()


return page