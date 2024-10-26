local GNUI = require"GNUI.main"
local Theme = require"GNUI.theme"
local Button = require"GNUI.element.button"
local Slider = require"GNUI.element.slider"
local TextField = require"GNUI.element.textField"
local eventLib = require"libraries.eventLib"
local screen = GNUI.getScreenCanvas()


-->========================================[ Page ]=========================================<--

---@alias GNUI.Dialog.any GNUI.Dialog.Button|GNUI.Dialog.RadioButton|GNUI.Dialog.Slider|GNUI.Dialog.TextField|GNUI.Dialog.Custom|GNUI.Dialog.Row|GNUI.Dialog.PageButton

---@class GNUI.Dialog.Element
---@field type string

---@class GNUI.Dialog.Row
---@field label string
---@field height number?
---@field content GNUI.Dialog.any[]?

---@class GNUI.Dialog.Button : GNUI.Dialog.Element
---@field text string
---@field onClick fun()

---@class GNUI.Dialog.PageButton : GNUI.Dialog.Element
---@field text string
---@field icon Minecraft.itemID
---@field pagePath string

---@class GNUI.Dialog.Custom : GNUI.Dialog.Element
---@field init fun(parent: GNUI.Box)
---@field onChange fun(index: integer)

---@class GNUI.Dialog.RadioButton : GNUI.Dialog.Element
---@field texts string
---@field selected integer
---@field onChange fun(index: integer)

---@class GNUI.Dialog.Slider : GNUI.Dialog.Element
---@field onChange fun()
---@field min number
---@field max number
---@field step number
---@field value number
---@field vertical boolean?

---@class GNUI.Dialog.TextField : GNUI.Dialog.Element
---@field textField string
---@field onConfirm fun(field: string)
---@field onChange fun(field: string)


---@alias GNUI.Dialog.Page.Positioning string
---| "MIDDLE"
---| "HOTBAR RIGHT"


---@class GNUI.Dialog.Page
---@field TICK EventLib
---@field FRAME EventLib
---@field PREPROCESS EventLib
---@field CLOSE EventLib
---@field name string?
---@field color Vector3?
---@field positioning GNUI.Dialog.Page.Positioning
---@field dialog GNUI.Dialog?
---@field rows GNUI.Dialog.Row[]
local Page = {}
Page.__index = Page

---Creates a new page data.
---@param data {name:string?,color:Vector3|string?,positioning:GNUI.Dialog.Page.Positioning?}?
---@return GNUI.Dialog.Page
function Page.new(data)
  data = data or {}
  local self = {
    name = data.name or "Unnamed Page",
---@diagnostic disable-next-line: param-type-mismatch
    color = (type(data.color) == "string" and vectors.hexToRGB(data.color) or data.color) or vec(1,1,1),
    rows = {},
    positioning = data.positioning,
    TICK  = eventLib.new(),
    FRAME = eventLib.new(),
    PREPROCESS  = eventLib.new(),
    CLOSE = eventLib.new()
  }
  setmetatable(self,Page)
  return self
end


---Creates a new row for elements to get inserted into.
---@param data string|GNUI.Dialog.Row?
function Page:newRow(data)
  data = data or {}
  if type(data) == "string" then
    data = {label = data}
  end
  local row = {
    label = data.label or "",
    height = data.height,
    content = {}
  }
  self.rows[#self.rows+1] = row
end



---@param data {label:string,init:fun(parent:GNUI.Box),height:number?}
function Page:newCustomUI(data)
  if data.label or data.height then self:newRow(data) end
  if not self.rows[1] then self:newRow() end
  
  local custom = {
    init = data.init,
    type = "Custom"
  }
  local row = self.rows[#self.rows]
  row.content[#row.content+1] = custom
  return self
end


function Page:newSeparator()
  self:newRow({label="",height=8})
  local btn = {
    type = "Separator"
  }
  local row = self.rows[#self.rows]
  row.content[#row.content+1] = btn
  return self
end


---@param data {label:string,text:any?,onClick:fun()?,isToggle:boolean?}
function Page:newButton(data)
  if data.label then self:newRow(data) end
  if not self.rows[1] then self:newRow() end
  
  local btn = {
    text = data.text,
    onClick = data.onClick,
    isToggle = data.isToggle,
    type = "Button"
  }
  local row = self.rows[#self.rows]
  row.content[#row.content+1] = btn
  return self
end

---@param data {text:string,icon:Minecraft.itemID,pagePath:string}
function Page:newPageButton(data)
  self:newRow({label="",height = 20})
  if not self.rows[1] then self:newRow() end
  
  local btn = {
    text = data.text,
    icon = data.icon,
    pagePath = data.pagePath,
    type = "PageButton",
  }
  local row = self.rows[#self.rows]
  row.content[#row.content+1] = btn
  return self
end

function Page:newReturnButton()
  self:newRow(" ")
  
  local btn = {
    text = "Return",
    onClick = function ()
      if self.dialog and #self.dialog.pageHistory > 0 then
        self.dialog.pageHistory[#self.dialog.pageHistory] = nil
        self.dialog:setPage(self.dialog.pageHistory[#self.dialog.pageHistory])
      end
    end,
    type = "Button"
  }
  local row = self.rows[#self.rows]
  row.content[#row.content+1] = btn
  return self
end

---@param data {label:string?,selected:integer?,texts:string[],onClick:fun(index:integer)?}
function Page:newRadioButton(data)
  if data.label then self:newRow(data) end
  if not self.rows[1] then self:newRow() end
  
  local btn = {
    selected = data.selected or 1,
    texts = data.texts,
    onClick = data.onClick,
    type = "RadioButton"
  }
  local row = self.rows[#self.rows]
  row.content[#row.content+1] = btn
  return self
end

---@param data {label:string,onChange:fun()?,min:number?,max:number?,step:number?,value:number?,vertical:boolean?}
function Page:newSlider(data)
  if data.label then self:newRow(data) end
  if not self.rows[1] then self:newRow() end
  
  local btn = {
    onChange = data.onChange,
    type = "Slider",
    min = math.min(data.min or 0,data.max or 10),
    max = math.max(data.min or 0,data.max or 10),
    vertical = data.vertical or false,
    step = data.step or 1,
  }
  btn.value = data.value or btn.min
  local row = self.rows[#self.rows]
  row.content[#row.content+1] = btn
  return self
end


---@param data {label:string?,onConfirm:fun(field:string)?,onChange:fun(field:string)?,textField:string?}
function Page:newTextField(data)
  if data.label then self:newRow(data) end
  if not self.rows[1] then self:newRow() end
  local btn = {
    onConfirm = data.onConfirm,
    onChange = data.onChange,
    textField = data.textField,
    type = "TextField"
  }
  local row = self.rows[#self.rows]
  row.content[#row.content+1] = btn
  return self
end


-->========================================[ Dialog ]=========================================<--


---@class GNUI.Dialog
---@field page GNUI.Dialog.Page?
---@field pageHistory GNUI.Dialog.Page[]
---@field box GNUI.Box
---@field clientArea GNUI.Box
---@field titlebar GNUI.Box
---@field positioning GNUI.Dialog.Page.Positioning
local Dialog = {}
Dialog.__type = "GNUI.Dialog"
Dialog.__index = Dialog


---@param parent GNUI.any
---@param positioning GNUI.Dialog.Page.Positioning
---@return GNUI.Dialog
function Dialog.new(parent,positioning)
  local self = {
    box = GNUI.newBox(parent),
    rows = {},
    positioning = positioning or "HOTBAR RIGHT",
    pageHistory = {},
  }
  ---@cast self GNUI.Dialog
  self.clientArea = GNUI.newBox(self.box)
  self.titlebar = GNUI.newBox(self.box)
  setmetatable(self,Dialog)
  Theme.style(self,"Default")
  events.WORLD_TICK:register(function () if self.page then self.page.TICK:invoke()end end)
  events.WORLD_RENDER:register(function () if self.page then self.page.FRAME:invoke()end end)
  return self
end


---@param page GNUI.Dialog.Page
---@return GNUI.Dialog
function Dialog:setPage(page)
  ---@cast self GNUI.Dialog
  if self.page then self.page.CLOSE:invoke() self.page.dialog = nil end
  local positioning = page.positioning or self.positioning
  if positioning == "HOTBAR RIGHT" then
    self.box:setAnchor(0.5,1,1,1)
    :setDimensions(93,-3,-3,-3)
    :setGrowDirection(1,-1)
  elseif positioning == "MIDDLE" then
    self.box:setAnchor(0.5,0.5)
    :setDimensions(-100,0,100,0)
    :setGrowDirection(1,0)
  end
  
  local clr = page.color or vec(1,1,1)
  self.titlebar
  :setDefaultTextColor(clr * 0.2)
  :setText(page.name)
  :setColor(clr)
  self.page = page
  if self.pageHistory[#self.pageHistory] ~= page then
    self.pageHistory[#self.pageHistory+1] = page
  end
  
  page.dialog = self
  
  -- Delete UI
  self.clientArea:purgeAllChildren()
  local y = 0
  
  
  -- Generate UI
  
  if self.page then self.page.PREPROCESS:invoke()end
  
  for i = 1, #page.rows, 1 do
    local row = page.rows[i]
    local height = row.height or 14
    local boxRow = GNUI.newBox(self.clientArea)
    :setAnchor(0,0,1,0)
    :setDimensions(2,y,0,y+height)
    :setChildrenOffset(0,1)
    :setZMul(i*10) -- sort by height
    y = y + height
    
    local labelBox = GNUI.newBox(boxRow)
    :setAnchor(0,0,0.5,1)
    :setText(row.label)
    :setTextAlign(1,1)
    :setTextOffset(-5,0)
    :setTextEffect("SHADOW")
    
    local elementsBox = GNUI.newBox(boxRow):setDimensions(0,0,-2,0)
    if #row.label > 0 then elementsBox:setAnchor(0.5,0,1,1)
    else elementsBox:setAnchor(0,0,1,1)
    end
    
    local contentCount = #row.content
    for c = 1, contentCount, 1 do
      local data = row.content[c]
      local elementBox = GNUI.newBox(elementsBox)
      :setAnchor((c-1)/contentCount,0,c/contentCount,1)
      
      local type = data.type
      if type == "Button" then -->==========[ Button ]==========<--
        local btn = Button.new(elementBox)
        :setAnchor(0,0,1,1)
        :setText(data.text)
        if data.onClick then btn.PRESSED:register(data.onClick) end
      
      elseif type == "RadioButton" then -->==========[ RadioButton ]==========<--
        local buttons = {} ---@type GNUI.Button[]
        local function renew()
          for j = 1, #buttons, 1 do
            local button = buttons[j]
            if data.selected == j then
              if not button.isPressed then button:press() end
            else
              if button.isPressed then button:press() end
            end
          end
        end
        for j = 1, #data.texts, 1 do
          local button = Button.new(elementBox):setToggle(true)
          :setAnchor((j-1)/#data.texts,0,j/#data.texts,1)
          :setText(data.texts[j])
          local o = j
          button.BUTTON_DOWN:register(function ()
            if data.selected ~= o then
              data.selected = o
              if data.onChange then data.onChange(o) end
              renew()
            end
          end)
          button.BUTTON_UP:register(renew)
          renew()
          buttons[j] = button
        end
      
      elseif type == "Slider" then -->==========[ Slider ]==========<--
        local btn = Slider.new(data.vertical,data.min,data.max,data.step,data.value,elementBox)
        :setAnchor(0,0,1,1)
        if data.onChange then btn.VALUE_CHANGED:register(function () data.onChange(btn.value) end) end
      elseif type == "TextField" then -->==========[ TextField ]==========<--
        local btn = TextField.new(elementBox)
        :setAnchor(0,0,1,1)
        :setText(data.textField)
        if data.onConfirm then btn.FIELD_CONFIRMED:register(data.onConfirm) end
        if data.onChange then btn.FIELD_CHANGED:register(data.onChange) end
      elseif type == "PageButton" then
        local base = Button.new(elementBox):setAnchor(0,0,1,1)
        local logo = GNUI.newBox(base):setAnchor(0,0.5):setPos(10,0):setCanCaptureCursor(false)
        local label = GNUI.newBox(base):setAnchor(0,0,1,1):setDefaultTextColor("black"):setText(data.text):setTextOffset(32,2):setTextAlign(0,0.5):setCanCaptureCursor(false)
        logo.ModelPart:newItem("icon"):item(data.icon):displayMode("GUI"):scale(1,1,1):pos(-4,0,-10)
        if page then base.PRESSED:register(function () page.dialog:setPage(require(data.pagePath))end) end
      elseif type == "Separator" then -->==========[ Separator ]==========<--
        local box = GNUI.newBox(elementBox):setAnchor(0,0.5,1,0.5):setDimensions(0,-1,0,0)
        box.__type = "Separator"
        Theme.style(box)
      elseif type == "Custom" then -->==========[ Custom ]==========<--
      
        if data.init then
          data.init(elementBox)
        end
      end
    end
    if self.page then
      self.box:setCustomMinimumSize(0,y+17)
    end
  end
  return self
end

-->========================================[ API ]=========================================<--

local api = {}

api.newDialog = Dialog.new
api.newPage = Page.new

return api