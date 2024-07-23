
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

---@class GNUI.Window.ImageViewer
---@field Ribbon GNUI.Stack
---@field RibbonBG GNUI.Container
---@field Preview GNUI.Container
local ImageViewer = {}
ImageViewer.__index = function (t,i)
   return rawget(t,i) or ImageViewer[i] or GNUIWindow.Window[i] or GNUI.Container[i] or GNUI.Element[i]
end
ImageViewer.__type = "GNUI.Window.ImageViewer"

function ImageViewer.new()
   local window = GNUIWindow.newWindow()
   :setSize(200,200)
   :setPos(16,16)
   :setTitle("Image Viewer")
   
   local Preview = GNUI.newContainer():setAnchor(0,0,1,1):setDimensions(5,5,-5,-5)
   window:addElement(Preview)
   window.Preview = Preview
   
   local Ribbon = GNUIElements.newStack():setIsHorizontal(true)
   :setAnchor(0,0,1,1):setDimensions(2,1,-2,-2)
   window.Ribbon = Ribbon
   
   local RibbonBG = GNUI.newContainer():setAnchor(0,0,1,0)
   :setDimensions(0,-1,0,10)
   GNUIThemes.applyTheme(RibbonBG,"solid")
   window.RibbonBG = RibbonBG
   
   RibbonBG:addChild(Ribbon)
   window:addElement(RibbonBG)
   
   local iconOpenImage = GNUI.newSprite():setTexture(textures["textures.icons"]):setUV(0,42,8,50)
   local openImageButton = GNUIElements.newSingleSpriteButton(iconOpenImage)
   :setCustomMinimumSize(9,9)
   openImageButton.PRESSED:register(function ()
      if not fileDialog then
         fileDialog = GNUIWindow.newFileDialog(screen,"OPEN")
         fileDialog.ON_FREE:register(function () fileDialog = nil end)
      end
   end)
   
   Ribbon:addChild(openImageButton)
   screen:addChild(window)
   setmetatable(window,ImageViewer)
   return window
end

function ImageViewer:openFile(path)
   if file:isFile(path) then
      local dataBuffer = data:createBuffer()
      dataBuffer:readFromStream(file:openReadStream(path))
      dataBuffer:setPosition(0)
      local texture = textures:read("GNWindowImagePreview",dataBuffer:readBase64())
      local sprite = GNUI.newSprite():setTexture(texture)
      self.Preview:setSprite(sprite)
   end
end


--ImageViewer:openFile("images/dog.png")

return ImageViewer