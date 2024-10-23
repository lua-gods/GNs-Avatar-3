
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
  label = "Row of Buttons",
  text = "1"
}
page:newButton{text = "2th"}
page:newButton{text = "3ft"}

page:newRadioButton({
  label="Radio Button",
  texts={
    "A",
    "B",
    "C",
    "D",
  }
})

page:newSlider({
  label = "Slider",
  min = 0,
  max = 10,
  step = 1,
  value = 5
})

page:newTextField({
  label = "Text Field",
  textField = "Text",
  onConfirm = function(text) print(text) end
})

panels:setPage(page)