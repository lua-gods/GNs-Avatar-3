---@diagnostic disable: undefined-field
local GNUI = require("GNUI.main")
-- GNUI Modules
local Elements = require("GNUI.modules.elements")
local Window = require("GNUI.modules.windows")
local Themes = require("GNUI.modules.themes")
-- Screen Stuffs
local screen = GNUI.getScreenCanvas()
local Statusbar = require("scriptHost.statusbar")
local icon = GNUI.newSprite():setTexture(textures["textures.icons"]):setUV(70,1,83,13)

local Button = Statusbar.newButtonSprite("Banner Editor",icon)

local banners = {
  "white_banner",
  "orange_banner",
  "magenta_banner",
  "light_blue_banner",
  "yellow_banner",
  "lime_banner",
  "pink_banner",
  "gray_banner",
  "light_gray_banner",
  "cyan_banner",
  "purple_banner",
  "blue_banner",
  "brown_banner",
  "green_banner",
  "red_banner",
  "black_banner"
}

local ibanners = {} -- reverse lookup
for i = 1, #banners, 1 do
  ibanners["minecraft:"..banners[i]] = i
end

local swatches = {
  "#f9fffe",
  "#f9801d",
  "#c74ebd",
  "#3ab3da",
  "#fed83d",
  "#80c71f",
  "#f38baa",
  "#474f52",
  "#9d9d97",
  "#169c9c",
  "#8932b8",
  "#3c44aa",
  "#835432",
  "#5e7c16",
  "#b02e26",
  "#1d1d21",
}
for i = 1, #swatches, 1 do
  swatches[i] = vectors.hexToRGB(swatches[i])
end

local patterns = {
  {code="b",name="Base"},
  {code="bs",name="Bottom Stripe"},
  {code="ts",name="Top Stripe"},
  {code="ls",name="Left Stripe"},
  {code="rs",name="Right Stripe"},
  {code="cs",name="Center Stripe"},
  {code="ms",name="Middle Stripe"},
  {code="drs",name="Down Right Strie"},
  {code="dls",name="Down Left Strie"},
  {code="ss",name="Small (Vertical) Stripes"},
  {code="cr",name="Diagonal Cross"},
  {code="sc",name="Square Cross"},
  {code="ld",name="Left of Diagonal"},
  {code="rud",name="Right of upside-down Diagonal"},
  {code="lud",name="Left of upside-down Diagonal"},
  {code="rd",name="Right of Diagonal"},
  {code="vh",name="Vertical Half (left)"},
  {code="vhr",name="Vertical Half (right)"},
  {code="hh",name="Horizontal Half (top)"},
  {code="hhb",name="Horizontal Half (bottom)"},
  {code="bl",name="Bottom Left Corner"},
  {code="br",name="Bottom Right Corner"},
  {code="tl",name="Top Left Corner"},
  {code="tr",name="Top Right Corner"},
  {code="bt",name="Bottom Triangle"},
  {code="tt",name="Top Triangle"},
  {code="bts",name="Bottom Triangle Sawtooth"},
  {code="tts",name="Top Triangle Sawtooth"},
  {code="mc",name="Middle Circle"},
  {code="mr",name="Middle Rhombus"},
  {code="bo",name="Border"},
  {code="cbo",name="Curly Border"},
  {code="bri",name="Brick"},
  {code="gra",name="Gradient"},
  {code="gru",name="Gradient upside-down"},
  {code="cre",name="Creeper"},
  {code="sku",name="Skull"},
  {code="flo",name="Flower"},
  {code="moj",name="Mojang"},
  {code="glb",name="Globe"},
  {code="pig",name="Piglin"},
  {code="flw",name="Flow"},
  {code="gus",name="Guster"}
}
local ipatterns = {} -- reverse lookup
for i = 1, #patterns, 1 do
  ipatterns[patterns[i].code] = i
end

local data = {
  {clr=0}
}
local window = Window.newWindow(true):setTitle("Banner Editor")
window:setPos(16,16):setSize(196,192)
screen:addChild(window)

local previewAnchor = GNUI.newContainer()
previewAnchor:setAnchor(0,0,1,1):setDimensions(0,0,-119,0)

local itemAnchor = GNUI.newContainer()
itemAnchor:setAnchor(0.5,1):setPos(0,-48)
previewAnchor:addChild(itemAnchor)

---@type ItemTask
local preview = itemAnchor.ModelPart:newItem("display"):scale(4,4,0.01)
preview:item("minecraft:white_banner")
window:addElement(previewAnchor)


local exportButton = Elements.newTextButton():setText("Export")
exportButton:setAnchor(0,1,1,1):setDimensions(-1,-16,1,1)
previewAnchor:addChild(exportButton)

local importButton = Elements.newTextButton():setText("I")
importButton:setAnchor(0,0,0,0):setDimensions(-1,-1,16,1)
previewAnchor:addChild(importButton)

local propertiesPanel = GNUI.newContainer()
propertiesPanel:setAnchor(1,0,1,1):setDimensions(-119,-1,1,1)
Themes.applyTheme(propertiesPanel,"solid")
window:addElement(propertiesPanel)

local slider = Elements.newScrollbarButton()
slider:setRange(0,10)
propertiesPanel:addChild(slider)

local outliner = Elements.newStack()
outliner:setAnchor(0,0,1,1):setDimensions(0,0,-7,0)
outliner:setMargin(-1)
outliner:setContainChildren(false)
propertiesPanel:addChild(outliner)

slider.ON_SCROLL:register(function (p)
  local y = p * 40
  outliner:setChildrenShift(0,y)
end)


---@param x number
---@param y number
---@param selected fun(selected:integer)
local function newSwatchWindow(x,y,selected)
  local swatchWindow = Window.newWindow()
  swatchWindow.isPopup = true
  swatchWindow:setPos(x,y):setTitle("Color"):setSize(63,73)
  local i = 0
  for z = 1, 4, 1 do
    for w = 1, 4, 1 do
      i = i + 1
      local swatch = Elements.newTextButton()
      swatch:setAnchor((z-1)/4,(w-1)/4,z/4,w/4):setDimensions(z == 1 and -1 or -0.5,w == 1 and -1 or -0.5,z == 4 and 1 or 0.5,w == 4 and 1 or 0.5)
      swatch.Sprite:setColor(swatches[i])
      local o = i
      swatch.PRESSED:register(function ()
        selected(o)
        swatchWindow:close()
      end)
      swatchWindow:addElement(swatch)
    end
  end
  swatchWindow.FOCUS_CHANGED:register(function (focus)
    if not focus then
      swatchWindow:close()
    end
  end)
  swatchWindow:setAsActiveWindow()
  screen:addChild(swatchWindow)
end


---@param x number
---@param y number
---@param selected fun(selected:integer)
local function newPatternWindow(x,y,control,selected)
  local pwin = Window.newWindow()
  pwin.isPopup = true
  pwin:setPos(x,y):setTitle("Select Pattern"):setSize(192,112)
  pwin.FOCUS_CHANGED:register(function (focus)
    if not focus then
      pwin:close()
    end
  end)
  local i = 1
  for z = 1, 11, 1 do
    for w = 1, 4, 1 do
      if patterns[i] then
        local btn = Elements.newButton()
        btn:setAnchor((z-1)/11,(w-1)/4,z/11,w/4)
        local item = btn.ModelPart:newItem("b"):setPos(-8.5,-18):scale(0.8,0.8,0.8)
        item:item("white_banner{BlockEntityTag:{Patterns:[{Pattern:"..(patterns[i].code)..",Color:"..(control.color-1).."}]}}")
        pwin:addElement(btn)
        local o = i
        btn.PRESSED:register(function ()
          selected(o)
          pwin:close()
        end)
      end
      i = i + 1
    end
  end
  pwin:setAsActiveWindow()
  screen:addChild(pwin)
end


local function updatePreview()
  local cat = ""
  for i = 2, #outliner.Children-1, 1 do
    local control = outliner.Children[i]
    cat = cat .. "{Pattern:"..patterns[control.pattern].code..",Color:"..(control.color-1).."},"
  end
  preview:item(banners[data[1].clr + 1].."{BlockEntityTag:{Patterns:["..cat:sub(1,-2).."]}}")
end

local function newLayer()
  local layer = GNUI.newContainer()
  layer:setCustomMinimumSize(0,32):setClipOnParent(true)
  Themes.applyTheme(layer,"solid")
  outliner:addChild(layer,#outliner.Children)
  
  local delete = Elements.newTextButton("nothing")
  delete:setAnchor(1,0):setDimensions(-8,0,0,8):setText("x")
  delete.PRESSED:register(function () layer:free() updatePreview() end)
  layer:addChild(delete)
  
  local up = Elements.newTextButton("nothing")
  up:setAnchor(0,0):setDimensions(0,0,16,16):setText("/\\")
  up.PRESSED:register(function () layer:setChildIndex(math.clamp(layer.ChildIndex-1,2,#outliner.Children-1)) updatePreview() end)
  layer:addChild(up)
  
  local down = Elements.newTextButton("nothing")
  down:setAnchor(0,1):setDimensions(0,-16,16,0):setText("\\/")
  down.PRESSED:register(function () layer:setChildIndex(math.clamp(layer.ChildIndex+1,2,#outliner.Children-1)) updatePreview() end)
  layer:addChild(down)
  
  
  local icontainer = GNUI.newContainer()
  icontainer:setAnchor(0,1):setPos(24,-9)
  local item = icontainer.ModelPart:newItem("b"):item(banners[1])
  
  local function updateIcon()
    item:item("white_banner{BlockEntityTag:{Patterns:[{Pattern:"..(patterns[layer.pattern].code)..",Color:"..(layer.color-1).."}]}}")
    updatePreview()
  end
  layer:addChild(icontainer)
  layer.updateIcon = updateIcon
  
  local colorPicker = Elements.newTextButton()
  colorPicker.PRESSED:register(function ()
    local gpos = layer:toGlobal(-1,-1)
    newSwatchWindow(gpos.x,gpos.y,function (selected)
      layer.color = selected
      updateIcon()
    end)
  end)
  colorPicker:setAnchor(0,0,1,0.5):setDimensions(40,0,-8,2):setText("Color")
  layer:addChild(colorPicker)
  
  local patternPicker = Elements.newTextButton()
  patternPicker.PRESSED:register(function ()
    local gpos = layer:toGlobal(-1,-1)
    newPatternWindow(gpos.x,gpos.y,layer,function (selected)
      layer.pattern = selected
      updateIcon()
    end)
  end)
  patternPicker:setAnchor(0,0.5,1,1):setDimensions(40,-1,-8,0):setText("Pattern")
  layer:addChild(patternPicker)
  
  layer.color = 16
  layer.pattern = 2
  updateIcon()
  return layer
end


local control = GNUI.newContainer()
control:setCustomMinimumSize(0,16)
Themes.applyTheme(control,"solid")
outliner:addChild(control)
control:setClipOnParent(true)

for i = 1, #swatches, 1 do
  local swatch = Elements.newButton()
  swatch:setSize(8,16):setPos((i-1)*7,0)

  local item = swatch.ModelPart:newItem("b"):item(banners[i]):scale(0.5,0.5,0.1):pos(-4,-12,0):rot(0,0,0)
  swatch.MOUSE_PRESSENCE_CHANGED:register(function (hovering,pressed)
    if hovering then item:scale(0.8,0.8,0.2)
    else item:scale(0.5,0.5,0.1)
    end
  end)
  swatch.PRESSED:register(function ()
    data[1].clr = i - 1
    updatePreview()
  end)
  control:addChild(swatch)
end

local newLayerButton = Elements.newTextButton("nothing")
newLayerButton:setText("+ New Layer"):setCustomMinimumSize(0,16)
outliner:addChild(newLayerButton:setClipOnParent(true))
newLayerButton.PRESSED:register(function () newLayer() end)




exportButton.PRESSED:register(function ()
  local cat = ""
  for i = 2, #outliner.Children-1, 1 do
    local layer = outliner.Children[i]
    cat = cat .. "{Pattern:"..patterns[layer.pattern].code..",Color:"..(layer.color-1).."},"
  end
  give(banners[data[1].clr + 1].."{BlockEntityTag:{Patterns:["..cat:sub(1,-2).."]}}")
end)

importButton.PRESSED:register(function ()
  local item = player:getHeldItem()
  if item and item.id:find("banner$") then
    data[1].clr = ibanners[item.id] - 1
    local p = item:getTag()
    if not p.BlockEntityTag or p.BlockEntityTag.Patterns then
      return
    end
    p = p.BlockEntityTag.Patterns
    outliner:purgeChildrenRange(2,#outliner.Children-1)
    for i = 1, #p, 1 do
      local layer = newLayer()
      layer.color = p[i].Color + 1
      layer.pattern = ipatterns[p[i].Pattern]
      layer.updateIcon()
    end
  end
end)


window.CLOSE_REQUESTED:register(function ()
  window:setVisible(false)
end)

window:setVisible(false)
Button.PRESSED:register(function ()
  window:setVisible(true)
  window:setPos(16,16):setSize(196,192)
end)