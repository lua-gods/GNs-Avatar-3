local Gradient = require("lib.gradient")
local endesga = require"lib.palettes.endesga64"

local GNUI = require("lib.GNUI.main")

local GradientEdit = require("lib.GNUI.element.gradientEdit")

local Pages = require"lib.pages"
local Button = require"lib.GNUI.element.button"
local TextField = require"lib.GNUI.element.textField"

local name = "Name"
local gradient = Gradient.new({
   [0] = endesga.lightGreen,
   [0.5] = endesga.brightGreen,
   [2] = endesga.lightGreen,
   [3] = endesga.darkGreen,
})

local page = Pages.newPage("nameplate",0)
---@param screen GNUI.Box
page.INIT:register(function (screen)
   local closeButton = Button.new(screen)
   :setSize(18,18)
   :setPos(40,40)
   :setText("X")
   .PRESSED:register(function ()
      Pages.returnPage()
   end)
   local preview = GNUI.newBox(screen)
   :setAnchor(0,0.5,1,0.5)
   :setSize(-128,64)
   :setPos(64,-128)
   :setTextAlign(0.5,0.5)
   :setFontScale(4)
   :setText("Preview")
   :setTextEffect("OUTLINE")
   
   local nameField = TextField.new(screen)
   :setAnchor(0,0.5,0.5,0.5)
   :setSize(-64,20)
   :setPos(64,-44)
   :setTextAlign(0.5,0.5)
   :setText("Name")
   :setTextEffect("OUTLINE")
   
   
   local function updatePreview()
      preview:setText(name)
   end
   nameField.FIELD_CHANGED:register(function (field)
      name = field
      updatePreview()
   end)
   
   local gradientBox = GradientEdit.new(screen)
   :setAnchor(0,0.5,0.5,0.5)
   :setSize(-64,20)
   :setPos(64,-14)
   :setGradient(gradient)
end)