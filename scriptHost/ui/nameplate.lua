
local plate = require("scripts.nameplate")
local GNUI = require("lib.GNUI.main")
local Pages = require"lib.pages"
local Button = require"lib.GNUI.element.button"
local TextField = require"lib.GNUI.element.textField"
local GradientEdit = require("lib.GNUIExtras.gradientEdit")

local page = Pages.newPage(
"nameplate",
{bgOpacity = 0.1,blur=false},
function (events, screen)
	renderer:setFOV(0.5)
   Button.new(screen)
   :setSize(18,18)
   :setPos(40,40)
   :setText("X")
   .PRESSED:register(function ()
      Pages.returnPage()
   end)
   
   local sidebar = GNUI.newBox(screen)
   :setAnchor(0,0.5,0.5,1)
   :setDimensions(4,4,-4,-4)
   :setText("Nameplate Display")
   :setTextEffect("OUTLINE")
   :setTextAlign(0.5,0)
   :setFontScale(1.5)
   
   local sidebar2 = GNUI.newBox(screen)
   :setAnchor(0.5,0.5,1,1)
   :setDimensions(4,4,-4,-4)
   :setText("Chat Name Hover")
   :setTextEffect("OUTLINE")
   :setTextAlign(0.5,0)
   :setFontScale(1.5)
   
   local hoverField = TextField.new(sidebar2,true)
   :setAnchor(0,0,1,1)
   :setDimensions(0,20,0,0)
   :setTextField(plate.hoverText)
   hoverField.FIELD_CONFIRMED:register(function (field)
      plate.hoverText = field
      plate.save()
   end)
   
   local nameField = TextField.new(sidebar,false)
   :setAnchor(0,0,1,0)
   :setSize(0,20)
   :setPos(0,20)
   :setTextEffect("OUTLINE")
   :setTextField(plate.name)
   
   local function updatePreview()
      plate.makeNameplate()
   end
   nameField.FIELD_CHANGED:register(function (field)
      plate.name = field
      updatePreview()
      plate.save()
   end)
   
   local gradientBox = GradientEdit.new(sidebar)
   :setAnchor(0,0,1,0)
   :setPos(0,42)
   :setSize(0,20)
   :setGradient(plate.gradient)
   gradientBox.GRADIENT_CHANGED:register(function ()
      plate.gradient = gradientBox.gradient
      updatePreview()
      --plate.save()
   end)
	
	function events.EXIT()
		renderer:setFOV()
	end
end)