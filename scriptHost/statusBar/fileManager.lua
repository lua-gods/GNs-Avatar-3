if not goofy then return end -- requires the goofy plugin

local GNUI = require("libraries.gnui")
local GNUIElements = require("libraries.gnui.modules.elements")
local GNUIWindow = require("libraries.gnui.modules.windows")
local screen = GNUI.getScreenCanvas()
local Statusbar = require("scriptHost.statusbar")
local theme = require("libraries.gnui.modules.themes")

local texture = textures["textures.icons"]
local icon = GNUI.newSprite():setTexture(texture):setUV(42,0,55,13)
local button = Statusbar.newButtonSprite(icon)

---@alias fileManagerType "OPEN"|"OPEN_MULTIPLE"|"SAVE"

---@param type fileManagerType?
---@return GNUI.window
local function newFileDialog(type)
   type = type or "OPEN_MULTIPLE"
   local window = GNUIWindow.newWindow()
   window:setDimensions(64,64,256,176)
   
   if type == "OPEN" then
      window:setTitle("File Dialog (Open a File)")
   elseif type == "OPEN_MULTIPLE" then
      window:setTitle("File Dialog (Open Files)")
   elseif type == "SAVE" then
      window:setTitle("File Dialog (Save a File)")
   end
   
   -->==========[ Sidebar ]==========<--
   
   local sidebar = GNUI.newContainer()
   theme.applyTheme(sidebar,"solid")
   sidebar:setAnchor(0,0,0,1):setDimensions(0,0,64,0)
   window:addElement(sidebar)
   
   -->==========[ Ribbon ]==========<--
   local ribbon = GNUI.newContainer()
   ribbon:setAnchor(0,0,1,0):setDimensions(0,0,0,16)
   window:addElement(ribbon)
   
   local pathField = GNUIElements.newTextInputField()
   pathField:setSize(-65-33,16):setPos(65,1):setAnchor(0,0,1,0)
   ribbon:addChild(pathField)
   
   local undoButton = GNUIElements.newTextButton():setText("<-")
   undoButton:setSize(16,16):setPos(2,1)
   ribbon:addChild(undoButton)
   
   local redoButton = GNUIElements.newTextButton():setText("->")
   redoButton:setSize(16,16):setPos(18,1)
   ribbon:addChild(redoButton)
   
   local upButton = GNUIElements.newTextButton():setText("^")
   upButton:setSize(16,16):setPos(34,1)
   ribbon:addChild(upButton)
   
   local downButton = GNUIElements.newTextButton():setText("()")
   downButton:setSize(16,16):setPos(50,1)
   ribbon:addChild(downButton)
   
   local filterButton = GNUIElements.newTextButton():setText("F")
   filterButton:setSize(16,16):setPos(-34,1):setAnchor(1,0,1,0)
   ribbon:addChild(filterButton)
   
   local sortByButton = GNUIElements.newTextButton():setText("S")
   sortByButton:setSize(16,16):setPos(-18,1):setAnchor(1,0,1,0)
   ribbon:addChild(sortByButton)
   
   -->==========[ Bottom Ribbon ]==========<--
   
   local bottomRibbon = GNUI.newContainer()
   bottomRibbon:setAnchor(0,0,1,0):setDimensions(0,-20,0,0):setAnchor(0,1,1,1)
   window:addElement(bottomRibbon)
   
   local fileNameField = GNUIElements.newTextInputField()
   fileNameField:setSize(-93,16):setPos(17,2):setAnchor(0,0,1,0)
   bottomRibbon:addChild(fileNameField)
   
   local cancelButton = GNUIElements.newTextButton():setText("Cancel")
   cancelButton:setSize(38,16):setPos(-40,2):setAnchor(1,0,1,0)
   bottomRibbon:addChild(cancelButton)
   
   local okButton = GNUIElements.newTextButton():setText("Open")
   okButton:setSize(38,16):setPos(-77,2):setAnchor(1,0,1,0)
   bottomRibbon:addChild(okButton)
   
   local OptionsButton = GNUIElements.newTextButton():setText("=")
   OptionsButton:setSize(16,16):setPos(2,2):setAnchor(0,0,0,0)
   bottomRibbon:addChild(OptionsButton)
   
   screen:addChild(window)
   return window
end

newFileDialog("OPEN")
button.PRESSED:register(function ()
   newFileDialog()
end)