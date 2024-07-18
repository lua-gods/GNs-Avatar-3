if not goofy then return end -- requires the goofy plugin

local GNUI = require("libraries.gnui")
local GNUIElements = require("libraries.gnui.modules.elements")
local GNUIWindow = require("libraries.gnui.modules.windows")
local screen = GNUI.getScreenCanvas()
local Statusbar = require("scriptHost.statusbar")

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
   
   local textInput = GNUIElements.newTextInputField()
   
   textInput:setDimensions(4,32,64,32)
   
   window:addChild(textInput)
   
   screen:addChild(window)
   return window
end

newFileDialog("OPEN")
button.PRESSED:register(function ()
   newFileDialog()
end)