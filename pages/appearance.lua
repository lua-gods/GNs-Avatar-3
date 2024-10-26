local Dialog = require"libraries.dialog"
local page = Dialog.newPage({
  name = "Appearance",
  color="#4cb150",
  positioning = "HOTBAR RIGHT",
})

local GNUI = require"GNUI.main"
local Button = require"GNUI.element.button"

page:newPageButton({
  text = "Nameplate",
  icon = "minecraft:name_tag",
  page = "pages.appearance.nameplate",
})

page:newSeparator()

page:newReturnButton()


return page