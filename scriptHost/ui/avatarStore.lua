local GNUI = require"lib.GNUI.main"
local Pages = require"lib.pages"
local Button = require"lib.GNUI.element.button"

local page = Pages.newPage("avatarStore")
---@param screen GNUI.Box
page.INIT:register(function (screen)
	screen:setText("Players")
	:setFontScale(2)
	:setTextOffset(22,8)
	:setTextEffect("OUTLINE")
	local username
	local left = GNUI.newBox(screen)
	:setAnchor(0,0,0.25,1)
	:setDimensions(4,32,-2,-4)
	
	Button.new(left) -- close button
	:setSize(16,16)
	:setText("x")
	:setTextOffset(0,-1)
	.PRESSED:register(function ()
		Pages.returnPage()
	end)
	
	local list = GNUI.newBox(left)
	:setAnchor(0,0,1,1)
	:setDimensions(0,32,0,-16)
	
	
	
	local reloadBtn = Button.new(left)
	:setAnchor(0,0,1,0)
	:setDimensions(16,0,0,16)
	:setText("Reload List")
	
	
	local right = GNUI.newBox(screen)
	:setAnchor(0.25,0,1,1)
	:setDimensions(2,32,-4,-4)
	
	local tabs = GNUI.newBox(right)
	:setAnchor(0,0,1,0)
	:setDimensions(0,0,0,16)
	
	local tab1 = Button.new(tabs)
	:setSize(100,16)
	:setText("Commands")
	:setToggle(true)
	
	local tab2 = Button.new(tabs)
	:setSize(100,16)
	:setPos(100,0)
	:setText("Stored")
	:setToggle(true)
	
	local tab3 = Button.new(tabs)
	:setSize(100,16)
	:setPos(200,0)
	:setText("Info")
	:setToggle(true)
	
	local page1 = GNUI.newBox(right)
	:setAnchor(0,0,1,1)
	:setDimensions(0,32,0,0)
	
	local page2 = GNUI.newBox(right)
	:setAnchor(0,0,1,1)
	:setDimensions(0,32,0,0)
	
	local page3 = GNUI.newBox(right)
	:setAnchor(0,0,1,1)
	:setDimensions(0,32,0,0)
	
	local lastTab = 1
	local function updateSubpages(i)
		i = i or lastTab
		lastTab = i
		tab1:setPressed(i == 1)
		tab2:setPressed(i == 2)
		tab3:setPressed(i == 3)
		
		page1:setVisible(tab1.isPressed)
		page2:setVisible(tab2.isPressed)
		page3:setVisible(tab3.isPressed)
		
		if i == 2 then
			page2:purgeAllChildren()
			local players = world.getPlayers()
			if not players[username] then return end
			local stored = players[username]:getVariable()
			local j = 0
			for key, value in pairs(stored) do
				Button.new(page2)
				:setAnchor(0,0,0.25,0)
				:setSize(0,20)
				:setPos(0,20*j)
				:setTextAlign(0,0.5)
				:setTextOffset(4,0)
				:setText(key)
				
				Button.new(page2,"none")
				:setAnchor(0.25,0,1,0)
				:setSize(0,20)
				:setPos(0,20*j)
				:setTextAlign(0,0.5)
				:setTextOffset(4,0)
				:setText(value)
				j = j + 1
			end
		end
	end
	
	tab1.BUTTON_DOWN:register(function() updateSubpages(1) end)
	tab2.BUTTON_DOWN:register(function() updateSubpages(2) end)
	tab3.BUTTON_DOWN:register(function() updateSubpages(3) end)
	updateSubpages(1)
	
	
	local function reloadList()
		list:purgeAllChildren()
		local playerList = client:getTabList().players
		for i = 1, #playerList, 1 do
			local name = playerList[i]
			local selectBtn = Button.new(list)
			:setAnchor(0,0,1,0)
			:setSize(0,20)
			:setPos(0,20*(i-1))
			:setTextAlign(0,0.5)
			:setTextOffset(32,0)
			:setText(name)
			
			selectBtn.PRESSED:register(function ()
				username = name
				updateSubpages()
			end)
			
			local icon = GNUI.newBox(selectBtn)
			icon.ModelPart:newItem("icon"):item('minecraft:player_head{SkullOwner:"'..name..'"}'):setPos(-10,-2):setScale(1.5,1.5,1)
		end
	end
	
	reloadBtn.PRESSED:register(function ()reloadList()end)
	reloadList()
end)