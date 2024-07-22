
local GNUI = require("libraries.gnui")
-- GNUI Modules
local GNUIElements = require("libraries.gnui.modules.elements")
local GNUIWindow = require("libraries.gnui.modules.windows")
local GNUIThemes = require("libraries.gnui.modules.themes")
-- Screen Stuffs
local screen = GNUI.getScreenCanvas()
local Statusbar = require("scriptHost.statusbar")
local icon = GNUI.newSprite():setTexture(textures["textures.icons"]):setUV(0,28,13,41)

local button = Statusbar.newButtonSprite(icon)

local fileDialog

local newImageViewer = function ()
   local window = GNUIWindow.newWindow()
   :setSize(200,200)
   :setPos(16,16)
   :setTitle("Image Viewer")
   
   local ribbon = GNUIElements.newStack():setIsHorizontal(true)
   :setAnchor(0,0,1,1):setDimensions(2,1,-2,-2)
   
   local ribbonBG = GNUI.newContainer():setAnchor(0,0,1,0)
   :setDimensions(0,-1,0,10)
   GNUIThemes.applyTheme(ribbonBG,"solid")
   
   ribbonBG:addChild(ribbon)
   window:addElement(ribbonBG)
   
   local iconOpenImage = GNUI.newSprite():setTexture(textures["textures.icons"]):setUV(0,42,8,50)
   local openImageButton = GNUIElements.newSingleSpriteButton(iconOpenImage)
   :setCustomMinimumSize(9,9)
   openImageButton.PRESSED:register(function ()
      if not fileDialog then
         fileDialog = GNUIWindow.newFileDialog(screen,"OPEN")
         fileDialog.ON_FREE:register(function () fileDialog = nil end)
      end
   end)
   
   ribbon:addChild(openImageButton)
   screen:addChild(window)
end