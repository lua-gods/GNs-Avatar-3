local Dialog = require"lib..dialog"
local page = Dialog.newPage({
  name = "Appearance",
  color="#4cb150",
  positioning = "HOTBAR RIGHT",
})

local GNUI = require"lib.GNUI.main"
local Button = require"lib.GNUI.element.button"

page:newPageButton({
  text = "Nameplate",
  icon = "minecraft:name_tag",
  page = "pages.appearance.nameplate",
})

page:newSeparator()

page:newReturnButton()


return page