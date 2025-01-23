local GNUI = require("lib.GNUI.main")
local Button = require"lib.GNUI.element.button"
local Slider = require"lib.GNUI.element.slider"


local Pages = require"lib.pages"
Pages.newPage(
"macros",
{blur=false},
function (events, screen)
	local returnButton = Button.new(screen)
	:setPos(10,10):setSize(11,11):setText("x"):setTextOffset(0.5,-1.5)
	returnButton.PRESSED:register(function ()Pages.returnPage()end)
	
	local list = GNUI.newBox(screen)
	:setAnchor(0,0,0.5,1)
	:setDimensions(20,20,-20,-20)
	
	local listScrollbar = Slider.new(true,0,10,0.1,0,screen)
	:setAnchor(0.5,0,0.5,1)
	:setSize(10,0)
end)