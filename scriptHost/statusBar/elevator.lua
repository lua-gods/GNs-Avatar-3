if not goofy then return end -- requires the goofy plugin

local GNUI = require("libraries.gnui")
local GNUIElements = require("libraries.gnui.modules.elements")
local GNUIWindow = require("libraries.gnui.modules.windows")
local screen = GNUI.getScreenCanvas()
local Statusbar = require("scriptHost.statusbar")
local sequence = require("libraries.sequence")

local icon = GNUI.newSprite():setTexture(textures["textures.icons"]):setUV(42,14,55,27)
local button = Statusbar.newButtonSprite(icon)
local window


local initialPos
local seqCopyElevator = sequence.new()
:add(0,function () initialPos = player:getPos() host:sendChatCommand("//1 6970,10,-3568") host:sendChatCommand("//2 6966,3,-3564") end)
:add(10,function () host:sendChatCommand("/tp 6968 6 -3568") end)
:add(20,function () host:sendChatCommand("//copy") end)
:add(25,function () host:sendChatCommand(("/tp %s %s %s"):format(initialPos.x,initialPos.y,initialPos.z)) end)



local function makeWindow()
   window = GNUIWindow.newWindow():setDimensions(0,16,128,236):setTitle("Elevator Utility")
   screen:addChild(window)
   
   local stack = GNUIElements.newStack():setAnchor(0,0,1,1):setDimensions(4,4,-4,-4)
   window:addElement(stack)
   
   local copyElevatorButton = GNUIElements.newTextButton():setText("Copy Elevator")
   stack:addChild(copyElevatorButton)
   copyElevatorButton.PRESSED:register(function ()
      seqCopyElevator:start(events.WORLD_TICK)
   end)
   
   local pasteElevatorButton = GNUIElements.newTextButton():setText("Paste Elevator")
   stack:addChild(pasteElevatorButton)
   pasteElevatorButton.PRESSED:register(function ()
      host:sendChatCommand("//paste") 
   end)
   
   stack:addChild(GNUI:newLabel():setCustomMinimumSize(0,50):setWrapText(true):setText("Stand inside the elevator so this utility can find the emerald block of the elevator"):setDefaultColor("gray"))
   local linkElevator = GNUIElements.newTextButton():setText("Link Elevator")
   stack:addChild(linkElevator)
   
   window.ON_FREE:register(function () window = nil end)
end

makeWindow()

button.PRESSED:register(function ()
   if window then
      window:free()
   else
      makeWindow()
   end
end)

