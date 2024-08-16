
local GNUI = require("GNUI.main")
-- GNUI Modules
local Elements = require("GNUI.modules.elements")
local Window = require("GNUI.modules.windows")
local Themes = require("GNUI.modules.themes")
-- Screen Stuffs
local screen = GNUI.getScreenCanvas()
local Statusbar = require("scriptHost.statusbar")
local icon = GNUI.newSprite():setTexture(textures["textures.icons"]):setUV(0,28,13,41)

local button = Statusbar.newButtonSprite("Gallery",icon)

local activeGalleries = 0
---@class GNUI.Window.Gallery : GNUI.Window
---@field Ribbon GNUI.Stack
---@field RibbonBG GNUI.Container
---@field Preview GNUI.Container
---@field StatusLabel GNUI.Label
---@field CameraPos Vector2
---@field Zoom number
---@field Image Texture
---@field Resolution Vector2
---@field PixelScale number
---@field OpenButton GNUI.Button
---@field InfoButton GNUI.Button
---@field ShadeButton GNUI.Button
---@field ZoomButton GNUI.Button
---@field ZoomLabel GNUI.Label
local Gallery = {}
Gallery.__index = function (t,i)
   return rawget(t,i) or Gallery[i] or Window.Window[i] or GNUI.Container[i] or GNUI.Element[i]
end
Gallery.__type = "GNUI.Window.Gallery"

function Gallery.new()
   activeGalleries = activeGalleries + 1
   ---@type GNUI.Window.Gallery
   local self = Window.newWindow()
   :setSize(200,200)
   :setPos(16,16)
   :setTitle("Gallery")
   
   local Preview = GNUI.newContainer():setCanCaptureCursor(false)--:setAnchor(0,0,1,1):setDimensions(5,5,-5,-5)
   self:addElement(Preview)
   self.Preview = Preview
   self.CameraPos = vec(0,0)
   self.Slot = activeGalleries
   self.Zoom = 1
   self.PixelScale = 1
   
   self.ClientArea.SIZE_CHANGED:register(function ()self:updateCamera()end)
   
   local Ribbon = Elements.newStack():setIsHorizontal(true)
   :setAnchor(0,0,1,1):setDimensions(2,1,-2,-2)
   self.Ribbon = Ribbon
   
   local RibbonBG = GNUI.newContainer():setAnchor(0,0,1,0)
   :setDimensions(-1,-1,1,10)
   Themes.applyTheme(RibbonBG,"solid")
   self.RibbonBG = RibbonBG
   
   RibbonBG:addChild(Ribbon)
   self:addElement(RibbonBG)
   
   -- Open image button
   local openImageButton = Elements.newSingleSpriteButton(GNUI.newSprite():setTexture(textures["textures.icons"]):setUV(0,42,8,50))
   :setCustomMinimumSize(9,9)
   openImageButton.PRESSED:register(function ()
      if self.fileDialog then
         self.fileDialog:close()
      end
      self.fileDialog = Window.newFileDialog(screen,"OPEN")
      self.fileDialog.ON_FREE:register(function () self.fileDialog = nil end)
      self.fileDialog.FILE_SELECTED:register(function (path) if path:find("%.png$") then self:openFile(path) end end)
   end)
   
   Ribbon:addChild(openImageButton)
   screen:addChild(self)
   self.OpenButton = openImageButton
   
   local statusLabel = GNUI.newLabel()
   :setAnchor(0,1)
   :setText("Open an Image...")
   :setPos(2,-9)
   self:addElement(statusLabel)
   statusLabel:setTextEffect("OUTLINE")
   self.StatusLabel = statusLabel
   
   -- shade mode button
   local iconShade1 = GNUI.newSprite():setTexture(textures["textures.icons"]):setUV(18,42,26,50)
   local iconShade2 = GNUI.newSprite():setTexture(textures["textures.icons"]):setUV(27,42,35,50)
   local shade = false
   local shadeImageButton = Elements.newSingleSpriteButton(iconShade1):setDimensions(-9,0,0,9)
   shadeImageButton.PRESSED:register(function ()
      if self.Preview.Sprite then
         shadeImageButton:setSprite(shade and iconShade1 or iconShade2)
         if shade then self.Preview.Sprite:setRenderType("EMISSIVE_SOLID")
         else self.Preview.Sprite:setRenderType("BLURRY") end
         shade = not shade
      end
   end)
   shadeImageButton:setAnchor(1,0,1,0)
   self:addElement(shadeImageButton)
   self.ShadeButton = shadeImageButton
   
   local zoomImageButton = Elements.newSingleSpriteButton(GNUI.newSprite():setTexture(textures["textures.icons"]):setUV(36,42,44,50))
   :setDimensions(18,0,9,9):setAnchor(.5,0,.5,0)
   self:addElement(zoomImageButton)
   self.ZoomButton = zoomImageButton
   
   local zoomLabel = GNUI.newLabel():setText("100%")
   :setDimensions(-18,1,9,10)
   :setAnchor(.5,0,.5,0)
   :setAlign(1,0)
   self:addElement(zoomLabel)
   self.ZoomLabel = zoomLabel
   
   self.ON_FREE:register(function ()
      activeGalleries = activeGalleries - 1
   end)
   
   local pan = false
   
   ---@param event GNUI.InputEvent
   self.ClientArea.INPUT:register(function (event)
      if event.key == "key.mouse.right" then
         pan = event.isPressed
      elseif event.key == "key.mouse.scroll" then
         self.Zoom = math.clamp(self.Zoom * (1+event.strength * 0.1),1,100)
         self:updateCamera()
      end
   end)
   
   self.ClientArea.MOUSE_MOVED:register(function (event)
      if pan then
         self.CameraPos:sub(event.relative * self.PixelScale)
         self:updateCamera()
      end
   end)
   
   setmetatable(self,Gallery)
   return self
end

function Gallery:updateCamera()
   if self.Image then
      local sprite = self.Preview.Sprite
      local zoom = .5 / self.Zoom
      local res = self.Resolution:copy():sub(2,2)
      local size = self.ClientArea.Size
      local aspect = (size.x / size.y) * (res.y / res.x)
      aspect = vec(1 / math.max(aspect,1),math.min(aspect,1))
      local margin = vec((size.x-(size.x * aspect.x)),(size.y-(size.y * aspect.y)))*.5
      self.PixelScale = res.x / (size.x-margin.x*2) * zoom * 2
      res = res * zoom
      self.CameraPos.x = math.clamp(self.CameraPos.x,res.x,self.Resolution.x-res.x-1)
      self.CameraPos.y = math.clamp(self.CameraPos.y,res.y,self.Resolution.y-res.y-1)
      local pos = self.CameraPos
      
      sprite:setUV(
         pos.x-res.x,
         pos.y-res.y,
         pos.x+res.x,
         pos.y+res.y
      )
      
      
      self.Preview:setDimensions(
         margin.x,
         margin.y,
         size.x-margin.x,
         size.y-margin.y
      )
      self.ZoomLabel:setText((math.floor(self.Zoom*100)).."%")
   end
end

function Gallery:openFile(path)
   if not self.Preview then
      self = Gallery.new()
   end
   if file:isFile(path) then
      local dataBuffer = data:createBuffer()
      dataBuffer:readFromStream(file:openReadStream(path))
      dataBuffer:setPosition(0)
      local data = dataBuffer:readBase64()
      local OK,result = pcall(textures.read,textures,"GNWindowImagePreview"..self.Slot,data)
      if OK then
         local dim = result:getDimensions()
         local sprite = GNUI.newSprite():setTexture(result)
         self.Preview:setSprite(sprite)
         self.CameraPos = dim * 0.5
         self.Zoom = 1
         self.Resolution = dim
         self.Image = result
         self.StatusLabel:setText(dim.x .. "x" .. dim.y.." | Size: "..(math.floor(#data/1024 * 100) / 100).."KB")
         self:updateCamera()
         self:setTitle("Gallery - " .. path)
      end
   end
end


button.PRESSED:register(function ()
   Gallery.new()
end)

return Gallery