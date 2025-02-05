local quickTween = require"scriptHost.ui.quickTween"

local GNUI = require("lib.GNUI.main")
local Button = require"lib.GNUI.element.button"
local Slider = require"lib.GNUI.element.slider"

local PATH = "macros"

local CONFIG_PATH = avatar:getName()..".macros"

local Pages = require"lib.pages"
Pages.newPage(
"macros",
{},
function (events, screen)
	
	local categories = {}
	
	local returnButton = Button.new(screen)
	:setPos(10,10):setSize(11,11):setText("x"):setTextOffset(0.5,-1.5)
	returnButton.PRESSED:register(function ()Pages.returnPage()end)
	
	local categoryBox = GNUI.newBox(screen)
	:setAnchor(0,0,0.25,1)
	:setDimensions(10,20,-10,-10)
	
	local categorySlider = Slider.new(categoryBox,{showNumber=false})
	:setAnchor(1,0,1,1)
	:setSize(10,0)
	:setPos(-10,0)
	
	
	local macrosBox = GNUI.newBox(screen)
	:setAnchor(0.25,0,1,0.75)
	:setDimensions(0,20,-10,0)
	
	local macrosSlider = Slider.new(macrosBox,{showNumber=false})
	:setAnchor(1,0,1,1)
	:setSize(10,0)
	:setPos(-10,0)
	
	local descriptonBox = GNUI.newBox(screen)
	:setAnchor(0.25,0.75,1,1)
	:setDimensions(0,0,-10,-10)
	:setText("Hover over a Macro to see it's description")
	
	
	local paths = listFiles(PATH,true)
	for i = 1,#paths do
		local path = paths[i]
		local category
		local name
		if paths[i]:find("%.") then
			category,name = paths[i]:match(PATH.."%.(.*)%.(.*)") --bobbies
			
		end
		if not categories[category] then
			categories[category] = {}
		end
		local macro,description = require(path)
		categories[category][name] = {macro=macro,description=description or "No description provided"}
	end
	
	local function loadCategory(category)
		macrosBox:removeChild(macrosSlider)
		:purgeAllChildren()
		macrosBox:addChild(macrosSlider)
		
		local i = 0
		for name, value in pairs(categories[category]) do
			local macroBtn = Button.new(macrosBox)
			:setAnchor(0,0,1,0)
			:setText(name)
			:setPos(i*20)
			:setSize(-10,(i+1)*20)
			:setTextAlign(0,0.5)
			:setTextOffset(10,0)
			
			local toggleLabel = GNUI.newBox(macroBtn)
			:setAnchor(1,0,1,1)
			:setDimensions(-50,0,0,0)
			:setTextAlign(0,0.5)
			
			local function setState(toggle)
				value.macro:setActive(toggle)
				if toggle then
					toggleLabel:setText({color="dark_green",text="Enabled"})
				else
					toggleLabel:setText({color="dark_red",text="Disabled"})
				end
			end
			
			config:setName(CONFIG_PATH)
			local enabled = config:load(category.."."..name) or false
			setState(enabled)
			
			macroBtn.PRESSED:register(function ()
				enabled = not enabled
				config:save(category.."."..name,enabled)
				setState(enabled)
			end)
			
			macroBtn.MOUSE_ENTERED:register(function ()
				descriptonBox:setText(value.description)
			end)
			
			i = i + 1
		end
	end
	
	local i = 0
	for key, value in pairs(categories) do
		local categoryBtn = Button.new(categoryBox)
		:setAnchor(0,0,1,0)
		:setText(key)
		:setPos(i*20)
		:setSize(-10,(i+1)*20)
		
		categoryBtn.PRESSED:register(function ()
			loadCategory(key)
		end)
		
		i = i + 1
	end
	
	loadCategory(next(categories))
	
	quickTween.left(categoryBox)
	quickTween.right(macrosBox)
	
end)