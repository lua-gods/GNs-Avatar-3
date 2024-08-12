
local GNUI = require("GNUI.main")
local GNUIElements = require("GNUI.modules.elements")
local GNUIWindow = require("GNUI.modules.windows")
local screen = GNUI.getScreenCanvas()
local Statusbar = require("scriptHost.statusbar")
local sequence = require("libraries.sequence")

local icon = GNUI.newSprite():setTexture(textures["textures.icons"]):setUV(42,14,55,27)
local button = Statusbar.newButtonSprite(icon)
local window

local elen = client.getTextWidth(".")

local function len(text)
   return client.getTextWidth("."..text..".")-elen*2
end

local initialPos
local elevatorPos
local name = ""
local indexPos
local seqCopyElevator = sequence.new()
:add(0,function () initialPos = player:getPos() host:sendChatCommand("//1 6970,10,-3568") host:sendChatCommand("//2 6966,3,-3564") end)
:add(10,function () host:sendChatCommand("/tp 6968 6 -3568") end)
:add(30,function () host:sendChatCommand("//copy") end)
:add(35,function () host:sendChatCommand(("/tp %f5 %f5 %f5"):format(initialPos.x,initialPos.y,initialPos.z)) end)
local pasted = false

local seqLinkElevator = sequence.new()
:add(0,function () initialPos = player:getPos() host:sendChatCommand("//1 7002,4,-3563") host:sendChatCommand("//2 7002,0,-3562") host:sendChatCommand("/tp 7002 0 -3563") end)
:add(20,function () host:sendChatCommand("//copy") end)
:add(40,function ()
   for y = 0, 10, 1 do
      for x = 0, -15, -1 do
         indexPos = vec(6991+x, y*6,-3553)
         if world.getBlockState(indexPos).id == "minecraft:air" then
            host:sendChatCommand(("/tp %s %s %s"):format(indexPos.x,indexPos.y,indexPos.z-1))
            return
         end
      end
   end
end)
:add(50,function () host:sendChatCommand("//paste") end)
:add(55,function () host:sendChatCommand("/fill ~ ~ ~ ~ ~1 ~1 air") host:sendChatCommand("/setblock ~ ~2 ~ air") end)
:add(55,function () host:sendChatCommand(('setblock ~ ~ ~1 minecraft:chain_command_block[facing=south]{Command:"execute as @e[tag=worldElevator] at @s run tp @s ~%i ~%i ~%i",auto:1b}'):format(-elevatorPos.x,-elevatorPos.y,-elevatorPos.z)) host:sendChatCommand(('setblock ~ ~1 ~1 minecraft:chain_command_block[facing=south]{Command:"execute as @e[tag=worldElevator] at @s run tp @s ~%i ~%i ~%i",auto:1b}'):format(elevatorPos.x,elevatorPos.y,elevatorPos.z)) end)
:add(60,function ()
   local split = {}
   local chunk = ""
   local chunkLength = 0
   for i = 1, #name, 1 do
      local char = name:sub(i,i)
      local l = len(char)
      chunk = chunk .. char
      chunkLength = chunkLength + l
      if chunkLength > 80 then
         chunkLength = 0
         split[#split+1] = chunk
         chunk = ""
      end
   end
   split[#split+1] = chunk
   host:sendChatCommand(([=[setblock ~ ~ ~ minecraft:cherry_wall_sign{front_text:{messages:['{"text":"%s"}','{"text":"%s"}','{"text":"%s"}','{"text":"%s"}']}}]=]):format(split[1] or "",split[2] or "",split[3] or "",split[4] or ""))
end)
:add(65,function ()
   local p = elevatorPos:copy():sub(2,-3,2)
   host:sendChatCommand(('tp %f5 %f5 %f5'):format(p.x,p.y,p.z))
end)
:add(80,function () host:sendChatCommand(('setblock %i %i %i air'):format(elevatorPos.x,elevatorPos.y+1,elevatorPos.z)) end)
:add(85,function ()
   host:sendChatCommand(('setblock %i %i %i minecraft:command_block[facing=up]{Command:"setblock %i %i %i minecraft:redstone_block"}'):format(elevatorPos.x,elevatorPos.y+1,elevatorPos.z,indexPos.x,indexPos.y+2,indexPos.z))
   initialPos = nil
   elevatorPos = nil
   name = ""
   indexPos = nil
   pasted = false
end)


local function makeWindow()
   window = GNUIWindow.newWindow():setDimensions(0,16,128,236):setTitle("Elevator Utility")
   screen:addChild(window)
   
   local stack = GNUIElements.newStack():setAnchor(0,0,1,1):setDimensions(4,4,-4,-4)
   window:addElement(stack)
   window:setSystemMinimumSize(128,64)
   
   stack:addChild(GNUI:newLabel():setCustomMinimumSize(0,40):setWrapText(true):setText("A utility that aims to automate most of the process when creating a new Auria Elevator"):setDefaultColor("gray"))
   
   local nameField = GNUIElements.newTextInputField():setPlaceholderText("Location Name")
   stack:addChild(nameField)
   nameField.TEXT_CONFIRMED:register(function (text) name = text end)
   
   local copyElevatorButton = GNUIElements.newTextButton():setText("1. Copy Template")
   stack:addChild(copyElevatorButton)
   copyElevatorButton.PRESSED:register(function ()
      seqCopyElevator:start(events.WORLD_TICK)
   end)
   
   local pasteElevatorButton = GNUIElements.newTextButton():setText("2. Paste Template")
   stack:addChild(pasteElevatorButton)
   pasteElevatorButton.PRESSED:register(function ()
      if pasted then
         host:sendChatCommand("//undo") 
      end
      pasted = true
      host:sendChatCommand("//paste") 
      elevatorPos = player:getPos():floor():add(2,-3,2)
   end)
   local undoPasteElevatorButton = GNUIElements.newTextButton():setText("Undo Paste")
   stack:addChild(undoPasteElevatorButton)
   undoPasteElevatorButton.PRESSED:register(function ()
      if pasted then
         elevatorPos = nil
         host:sendChatCommand("//undo") 
      end
   end)
   
   local linkElevator = GNUIElements.newTextButton():setText("3. Confirm & Link")
   linkElevator.PRESSED:register(function ()
      if elevatorPos then
         seqLinkElevator:start(events.WORLD_TICK)
      end
   end)
   stack:addChild(linkElevator)
   
   window.ON_FREE:register(function () window = nil end)
end

button.PRESSED:register(function ()
   if window then
      window:free()
   else
      makeWindow()
   end
end)

