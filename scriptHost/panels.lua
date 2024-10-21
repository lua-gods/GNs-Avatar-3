
local GNUI = require"GNUI.main"
local Theme = require"GNUI.theme"
local Button = require"GNUI.element.button"
local screen = GNUI.getScreenCanvas()

local Dialog = require"libraries.dialog"

local panels = Dialog.newDialog(screen)
panels.box
:setAnchor(0.5,1,1,1)
:setDimensions(93,-3,-3,-3)
:setGrowDirection(1,-1)
:setCustomMinimumSize(0,100)


local page = Dialog.newPage()
page:newButton{
  label = "Example",
  text = "woag"
}

page:newButton{
  label = "Anoatha One",
  text = "woage"
}
page:newButton{text = "x2"}
page:newButton{text = "x2"}

panels:setPage(page)