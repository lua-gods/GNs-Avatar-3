local Dialog = require"lib.dialog"
local page = Dialog.newPage({
  name = "GN's Avaar | on GNUI v3",
  color="#99e65f",
  positioning = "HOTBAR RIGHT",
})

local GNUI = require"lib.GNUI.main"
local Button = require"lib.GNUI.element.button"

page:newPageButton({
  text ="Appearance",
  icon = "minecraft:leather_chestplate{display:{color:6282596}}",
  page = "pages.appearance"
})
page:newPageButton({
  text = "Macros",
  icon = "minecraft:redstone",
  page = "pages.macros"
})
page:newPageButton({
  text = "Players",
  icon = "minecraft:player_head",
  page = "pages.players"
})

page:newSeparator()
page:newPageButton({
  text = "Debug Info",
  icon = "minecraft:creeper_banner_pattern"
})
page:newPageButton({
  text = "UI Demo",
  icon = "minecraft:firework_rocket",
  page = "pages.demo"
})

--keybinds:fromVanilla("key.jump"):onPress(function () return true end)

return page