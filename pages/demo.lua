local Dialog = require"libraries.dialog"
local page = Dialog.newPage()


page:newButton{
  label = "Example",
  text = "woag"
}

page:newRow("Example Label lmaoo")

page:newButton{
  label = "Row of Buttons",
  text = "1"
}
page:newButton{text = "2th"}
page:newButton{text = "3ft"}

page:newSlider({
  label = "Slider",
  min = 0,
  max = 10,
  step = 1,
  value = 5
})

page:newRadioButton({
  label="Radio Button",
  texts={
    "A",
    "B",
    "C",
    "D",
  }
})

page:newRow({
  label = "Vertical Sliders",
  height = 60,
})


for i = 1, 5, 1 do
  page:newSlider({
    min = 0,
    max = 10,
    step = 1,
    value = 5,
    vertical = true,
  })
end

page:newTextField({
  label = "Text Field",
  textField = "Text",
  onConfirm = function(text) print(text) end
})

page:newPageButton({
  text = "Page Button",
  icon="minecraft:grass_block",
  pagePath = "pages.demo"
})

page:newReturnButton()

return page