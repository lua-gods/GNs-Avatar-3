local Dialog = require"libraries.dialog"
local page = Dialog.newPage({
  name = "GN's Avaar | on GNUI v3",
  color="#99e65f",
  positioning = "HOTBAR RIGHT",
})

local GNUI = require"GNUI.main"
local Button = require"GNUI.element.button"

page:newRow("")
page:newPageButton({
  text ="Appearance",
  icon = "minecraft:leather_chestplate{display:{color:6282596}}",
  pagePath = "pages.appearance"
})
page:newPageButton({
  text = "User Interface",
  icon = "minecraft:painting",
  pagePath = "pages.ui"
})
page:newPageButton({
  text = "Utilities",
  icon = "minecraft:name_tag",
  pagePath = "pages.utilities"
})
page:newPageButton({
  text = "Command Utilities",
  icon = "minecraft:command_block"
})

page:newSeparator()
page:newPageButton({
  text = "Debug Info",
  icon = "minecraft:creeper_banner_pattern"
})

return page