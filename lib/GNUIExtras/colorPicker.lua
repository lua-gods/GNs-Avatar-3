---@diagnostic disable: undefined-global, assign-type-mismatch
--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / a color picker
/ /_/ / /|  / 
\____/_/ |_/ Source: https://github.com/lua-gods/GNs-Avatar-3/blob/main/lib/GNUIExtras/colorPicker.lua]]

local path = require("./path")
local Box = require(path.."../primitives/box") ---@type GNUI.Box
local cfg = require(path.."../config") ---@type GNUI.Config
local Nineslice = require(path.."../nineslice") ---@type Nineslice
local eventLib = cfg.event ---@type EventLibAPI ---@type EventLibAPI
local Theme = require(path.."../theme") ---@type GNUI.ThemeAPI
local Button = require(path.."button") ---@type GNUI.Button
local TextField = require(path.."textField") ---@type GNUI.TextField
local Slider = require(path.."slider") ---@type GNUI.Slider
local utils = cfg.utils ---@type GNUI.UtilsAPI

local TAU = math.pi * 2

local MODES = {
   "RGB",
   "HSV",
}

local HEADER_SIZE = 16
local WIDTH = 100
local PREVIEW_SIZE = 12
local SLIDER_WIDTH = 12
local MODE_HEIGHT = 12
local HEX_FIELD_SIZE = 12
local SLIDER_SIZE = 7
local PICKER_RADIUS = 5


local DISAPPEAR_MARGIN = 20

---@param p Vector2
---@param b Vector2
local function boxDistance(p,b)
   local d = vec(math.abs(p.x),math.abs(p.y))-b
   return (vec(math.max(d.x,0),math.max(d.y,0)) + math.min(math.max(d.y,d.x),0)):length()
end

local existingPickers = {}

---@class GNUI.ColorPicker : GNUI.Box
---@field Color Vector3
---@field ColorHSV Vector3
---@field COLOR_CHANGED EventLib
---@field updateInputs fun(self: GNUI.ColorPicker,forced?: boolean):GNUI.ColorPicker
local ColorPicker = {}
ColorPicker.__index = function (t,i) return rawget(t,i) or ColorPicker[i] or Box[i] end
ColorPicker.__type = "GNUI.ColorPicker"

local colorTexture = textures:newTexture("GNUI_colorPicker",256,256)
local white = textures["1x1white"] or textures:newTexture("1x1white",1,1):setPixel(0,0,vec(1,1,1))

local function sample(x,y)
   x = x * 2
   y = y * 2
   if x < 1 and y < 1 then
      local offset = vec(x-0.5,y-0.5)
      local r = math.atan2(-offset.x,offset.y)/math.pi/2
      local d = offset:length()*2
      return vectors.hsvToRGB(r,math.min(d,1),1):augmented(math.clamp((1-d)*25,0,1))
   elseif x > 1 and y < 1 then
      local a = 1-y
      return vec(1,1,1,a)
   elseif x < 1 and y > 1 then
      local a = x-1
      return vec(1,1,1,a)
   elseif x > 1 and y > 1 then
      local d = vec(x-1.5,y-1.5):length()*2
      local a = math.clamp((0.7-d)*10,0,1)
      return vec(a,a,a,math.clamp((1-d)*10,0,1))
   end
end

do
   local res = 2
   local invRes = 128
   local x = 0
   local y = 0
   events.WORLD_RENDER:register(function (delta)
      for i = 1, 50, 1 do
         colorTexture:fill(x*invRes,y*invRes,invRes,invRes,sample((x+0.5)/res,(y+0.5)/res))
         colorTexture:update()
         x = x + 1
         if x >= res then
            x = 0
            y = y + 1
            if y >= res then
               y = 0
               res = res * 2
               invRes = invRes / 2
               if res >128 then
                  events.WORLD_RENDER:remove("GNUI_colorPicker")
               end
            end
         end
      end
   end,"GNUI_colorPicker")
end

---@param parent GNUI.Box
---@param x number|Vector2
---@param y number?
function ColorPicker.new(parent,x,y)
   for key, value in pairs(existingPickers) do value:free()end
   local pos = utils.vec2(x,y)
   pos.x = math.clamp(pos.x,0,parent.Size.x-WIDTH)
   pos.y = math.clamp(pos.y,0,parent.Size.y-(WIDTH+MODE_HEIGHT+PREVIEW_SIZE+SLIDER_WIDTH*3+HEX_FIELD_SIZE+17))
   ---@type GNUI.ColorPicker
   local box = Box.new(parent)
   Theme.style(box,"Background")
   box._parent_class = ColorPicker
   box:setSize(WIDTH,WIDTH+MODE_HEIGHT+PREVIEW_SIZE+SLIDER_WIDTH*3+HEX_FIELD_SIZE)
   :setZMul(10)
   :setPos(pos)
   setmetatable(box,ColorPicker)
   existingPickers[#existingPickers+1] = box
   
   local pickerBox = Box.new(box)
   :setPos(0,HEADER_SIZE)
   :setSize(WIDTH,WIDTH-HEADER_SIZE)
   
   local headerBox = Box.new(box)
   :setAnchor(0,0,1,0)
   :setSize(0,HEADER_SIZE)
   :setText("Color Picker")
   :setTextOffset(1,1)
   :setTextAlign(0.5,0.5)
   Theme.style(headerBox,"Background")
   
   local mode1Box = Box.new(pickerBox)
   :setAnchor(0,0,1,1)
   
   local wheelBox = Box.new(mode1Box)
   :setNineslice(Nineslice.new():setTexture(colorTexture):setRenderType("BLURRY"):setUV(1,1,126,126))
   :setAnchor(0,0,1,1)
   :setDimensions(0,0,-HEADER_SIZE,0)
   
   local brightnessBoxBlack = Box.new(mode1Box)
   :setNineslice(Nineslice.new():setTexture(white):setColor(0,0,0):setRenderType("EMISSIVE_SOLID"):setExpand(-2,-1,-2,-1))
   :setAnchor(1,0,1,1)
   :setDimensions(-HEADER_SIZE,0,0,0)
   
   local brightnessBox = Box.new(mode1Box)
   :setNineslice(Nineslice.new():setTexture(colorTexture):setRenderType("CUTOUT_EMISSIVE_SOLID"):setUV(127,0,255,127):setExpand(-2,-1,-2,-1))
   :setAnchor(1,0,1,1)
   :setDimensions(-HEADER_SIZE,0,0,0)
   
   local brightnessSlider = Button.new(brightnessBox,"Flat")
   :setSize(0,SLIDER_SIZE)
   
   local pickerSelector = Box.new(wheelBox)
   :setNineslice(Nineslice.new():setTexture(colorTexture):setRenderType("TRANSLUCENT"):setUV(128,128,255,255))
   :setDimensions(-PICKER_RADIUS,-PICKER_RADIUS,PICKER_RADIUS,PICKER_RADIUS)
   
   local previewBox = Box.new(box)
   :setNineslice(Nineslice.new():setTexture(white))
   :setAnchor(0,0,1,0)
   :setDimensions(1,WIDTH+1,-1,WIDTH+PREVIEW_SIZE-1)
   
   local infoBox = Box.new(box)
   :setAnchor(0,0,1,1)
   :setDimensions(0,WIDTH+PREVIEW_SIZE,0,0)
   
   box.COLOR_CHANGED = eventLib.newEvent()
   
   local mode = 1
   
   local colorPickerButton = Button.new(infoBox)
   :setAnchor(1,0,1,0)
   :setDimensions(-HEX_FIELD_SIZE,MODE_HEIGHT,0,MODE_HEIGHT+HEX_FIELD_SIZE)
   :setText("+")
   
   local hexField = TextField.new(infoBox,"none")
   :setAnchor(0,0,1,0)
   :setDimensions(0,MODE_HEIGHT,-HEX_FIELD_SIZE,MODE_HEIGHT+HEX_FIELD_SIZE)
   :setTextAlign(0.5,0.5)
   :setText("#000000")
   
   local slider1 = Slider.new(false,0,255,1,0,infoBox)
   :setAnchor(0,1,1,1)
   :setPos(0,-SLIDER_WIDTH*3)
   :setSize(0,SLIDER_WIDTH)
   
   local slider2 = Slider.new(false,0,255,1,0,infoBox)
   :setAnchor(0,1,1,1)
   :setPos(0,-SLIDER_WIDTH*2)
   :setSize(0,SLIDER_WIDTH)
   
   local slider3 = Slider.new(false,0,255,1,0,infoBox)
   :setAnchor(0,1,1,1)
   :setPos(0,-SLIDER_WIDTH)
   :setSize(0,SLIDER_WIDTH)
   
   box.Color = vec(1,1,1)
   box.ColorHSV = vec(1,1,1)
   
   local lastColor = box.Color
   local lastTime = 0
   local function updateInputs(forced)
      local clr = box.Color
      local hsv = box.ColorHSV
      local thisTime = client:getSystemTime()
      if thisTime-lastTime > 10 or forced then
         lastTime = thisTime
         brightnessSlider
         :setAnchor(0,1-hsv.z,1,1-hsv.z)
         :setPos(0,SLIDER_SIZE*(hsv.z-1))
         if mode == 2 then
            slider1:setValue(hsv.x*255)
            slider2:setValue(hsv.y*255)
            slider3:setValue(hsv.z*255)
         elseif mode == 1 then
            slider1:setValue(clr.x*255)
            slider2:setValue(clr.y*255)
            slider3:setValue(clr.z*255)
         end
         hexField:setTextField("#"..vectors.rgbToHex(clr))
         
         pickerSelector:setAnchor(-math.sin(hsv.x * TAU)*0.5*hsv.y+0.5,math.cos(hsv.x * TAU)*0.5*hsv.y+0.5)
         wheelBox.Nineslice:setColor(hsv.zzz)
         if lastColor ~= clr then
            lastColor = clr
            box.COLOR_CHANGED:invoke(clr)
         end
      end
      
      
      previewBox.Nineslice:setColor(box.Color)
   end
   updateInputs()
   
   box.updateInputs = function (self,forced) updateInputs(forced) return box end
   
   ---@param event GNUI.InputEventMouseMotion
   brightnessSlider.MOUSE_MOVED:register(function (event)
      if brightnessSlider.isPressed then
         box.ColorHSV.z = math.clamp(box.ColorHSV.z - event.relative.y / (brightnessBox.Size.y-SLIDER_SIZE),0,1)
         box.Color = vectors.hsvToRGB(box.ColorHSV)
         updateInputs()
      end
   end)
   
   for i = 1, #MODES, 1 do
      local o = i
      Button.new(infoBox)
      :setAnchor((i-1)/#MODES,0,i/#MODES,0)
      :setSize(0,MODE_HEIGHT)
      :setText(MODES[i])
      .PRESSED:register(function ()
         mode = o
         updateInputs()
      end)
   end
   
   pickerSelector:setCanCaptureCursor(false)
   local isSelectorPressed = false
   wheelBox.INPUT:register(function (event)
      if event.key == "key.mouse.left" then
         isSelectorPressed = event.state == 1
      end
   end)
   
   ---@param event GNUI.InputEventMouseMotion
   wheelBox.MOUSE_MOVED:register(function (event)
      if isSelectorPressed then
         local hsv = box.ColorHSV
         local mpos = (wheelBox:toLocal(event.pos) / wheelBox.Size - 0.5) * 2
         local angle = (math.atan2(-mpos.x,mpos.y) / math.pi / 2) % 1
         local dist = math.min(mpos:length(),1)
         box.ColorHSV = vec(angle,dist,hsv.z)
         box.Color = vectors.hsvToRGB(box.ColorHSV)
         updateInputs()
      end
   end)
   
   hexField.FIELD_CONFIRMED:register(function (text)
      local hex = text:gsub("#","")
      box.Color = vectors.hexToRGB(hex)
      updateInputs()
   end)
   
   slider1.VALUE_CHANGED:register(function (value)
      if mode == 1 then box:setColor(value/255,box.Color.y,box.Color.z)
      elseif mode == 2 then local hsv = box.ColorHSV; box:setColorHSV(value/255,hsv.y,hsv.z)
      end updateInputs()
   end)
   
   slider2.VALUE_CHANGED:register(function (value)
      if mode == 1 then box:setColor(box.Color.x,value/255,box.Color.z)
      elseif mode == 2 then local hsv = box.ColorHSV; box:setColorHSV(hsv.x,value/255,hsv.z)
      end updateInputs()
   end)
   
   slider3.VALUE_CHANGED:register(function (value)
      if mode == 1 then box:setColor(box.Color.x,box.Color.y,value/255)
      elseif mode == 2 then local hsv = box.ColorHSV; box:setColorHSV(hsv.x,hsv.y,value/255)
      end updateInputs()
   end)
   
   
   local mouseEntered = false
   local pardonMouseExit = false
   local firstMouseMove = true
   
   local function canvasInit(newCanvas,oldCanvas)
      if oldCanvas then
         oldCanvas.MOUSE_MOVED_GLOBAL:remove("GNUI.popup"..box.id)
      end
      if newCanvas then
         ---@param event GNUI.InputEventMouseMotion
         newCanvas.MOUSE_MOVED_GLOBAL:register(function (event)
            if firstMouseMove then firstMouseMove = false return end
            local halfSize = box.Size/2
            local mpos = newCanvas.MousePosition - box.ContainmentRect.xy - halfSize
            local dist = boxDistance(mpos,halfSize)
            if dist < DISAPPEAR_MARGIN or box:isPosInside(box.Parent:toLocal(event.pos)) then
               mouseEntered = true
            else
               if mouseEntered then
                  mouseEntered = false
                  if not pardonMouseExit then
                     newCanvas.MOUSE_MOVED_GLOBAL:remove("GNUI.popup"..box.id)
                     box:free()
                  end
                  pardonMouseExit = false
               end
            end
         end,"GNUI.popup"..box.id)
      end
   end
   
   box.CANVAS_CHANGED:register(canvasInit)
   canvasInit(box.Canvas)
   
   
   local canvas
   colorPickerButton.PRESSED:register(function ()
      canvas = colorPickerButton.Canvas
      pardonMouseExit = true
      ---@param event GNUI.InputEvent
      canvas.INPUT:register(function (event)
         if event.state == 0 and event.key == "key.mouse.left" then
            local screenshot = host:screenshot("screenshot")
            local mpos = canvas.MousePosition * client:getGuiScale()
            box.Color = screenshot:getPixel(mpos.x,mpos.y).xyz
            box.ColorHSV = vectors.rgbToHSV(box.Color)
            canvas.INPUT:remove("GNUI.color_picker")
            updateInputs()
         end
         return true
      end,"GNUI.color_picker")
   end)
   
   return box
end

---Sets the color of the color picker in RGB.
---@param r number|Vector3
---@param g number?
---@param b number?
---@return GNUI.ColorPicker
function ColorPicker:setColor(r,g,b)
   local vec = utils.vec3(r,g,b)
   self.ColorHSV = vectors.rgbToHSV(vec)
   self.Color = vec
   self:updateInputs(true)
   return self
end

---Sets the color of the color picker in HSV.
---@param h number|Vector3
---@param s number?
---@param v number?
---@return GNUI.ColorPicker
function ColorPicker:setColorHSV(h,s,v)
   local vec = utils.vec3(h,s,v)
   self.Color = vectors.hsvToRGB(vec)
   self.ColorHSV = vec
   self:updateInputs(true)
   return self
end

return ColorPicker