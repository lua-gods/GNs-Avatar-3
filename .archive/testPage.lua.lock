local GNUI = require("lib.GNUI.main")
local Themes = require("lib.GNUI.theme")

local Pages = require"lib.pages"
local Button = require"lib.GNUI.element.button"

local page = Pages.newPage("testPage",{
	bgOpacity = 0,
})
---@param screen GNUI.Box
page.INIT:register(function (screen)
   
	local btn1 = Button.new(screen)
	:setPos(10,30)
	:setSize(100,50)
	:setText("test")
	
	local panel = GNUI.newBox(screen)
	:setPos(20,20)
	:setSize(100,100)
	Themes.style(panel,"Background")
	
	local btn = Button.new(panel)
	:setPos(30,30)
	:setSize(100,50)
	:setText("test")
	
	
end)