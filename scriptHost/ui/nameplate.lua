local Gradient = require("lib.gradient")
local endesga = require"lib.palettes.endesga64"

local GNUI = require("lib.GNUI.main")

local GradientEdit = require("lib.GNUIExtras.gradientEdit")

local Pages = require"lib.pages"
local Button = require"lib.GNUI.element.button"
local TextField = require"lib.GNUI.element.textField"

local page = Pages.newPage("nameplate",{bgOpacity = 0.1})
---@param screen GNUI.Box
page.INIT:register(function (screen)
   renderer:setFOV(0.5)
   local plate = require("scripts.nameplate")
   local closeButton = Button.new(screen)
   :setSize(18,18)
   :setPos(40,40)
   :setText("X")
   .PRESSED:register(function ()
      Pages.returnPage()
   end)
   
   local nameField = TextField.new(screen)
   :setAnchor(0,0.5,1,0.5)
   :setSize(-256,20)
   :setPos(128,0)
   :setTextAlign(0.5,0.5)
   :setTextEffect("OUTLINE")
   :setTextField(plate.name)
   
   local function updatePreview()
      plate.makeNameplate()
   end
   nameField.FIELD_CHANGED:register(function (field)
      plate.name = field
      updatePreview()
   end)
   
   local gradientBox = GradientEdit.new(screen)
   :setAnchor(0,0.5,1,0.5)
   :setSize(-256,20)
   :setPos(128,24)
   :setGradient(plate.gradient)
   gradientBox.GRADIENT_CHANGED:register(function ()
      plate.gradient = gradientBox.gradient
      updatePreview()
   end)
end)
page.EXIT:register(function ()
   renderer:setFOV()
end)