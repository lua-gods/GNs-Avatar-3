local GNUI = require"GNUI.main"
local Theme = require"GNUI.theme"
local Button = require"GNUI.element.button"
local Slider = require"GNUI.element.slider"
local TextField = require"GNUI.element.textField"
local eventLib = require"libraries.eventLib"
local screen = GNUI.getScreenCanvas()


-->========================================[ Page ]=========================================<--

---@alias GNUI.Dialog.any GNUI.Dialog.Button|GNUI.Dialog.RadioButton|GNUI.Dialog.Slider|GNUI.Dialog.TextField

---@class GNUI.Dialog.Element
---@field type string

---@class GNUI.Dialog.Row
---@field label string
---@field content GNUI.Dialog.any[]?

---@class GNUI.Dialog.Button : GNUI.Dialog.Element
---@field text string
---@field onClick fun()

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

---@class GNUI.Dialog.TextField : GNUI.Dialog.Element
---@field textField string
---@field onConfirm fun(field: string)
---@field onChange fun(field: string)

---@class GNUI.Dialog.Page
---@field name string?
---@field rows GNUI.Dialog.Row[]
local Page = {}
Page.__index = Page

---Creates a new page data.
---@return GNUI.Dialog.Page
function Page.new()
  local self = {
    name = "Unnamed Page",
    rows = {},
  }
  setmetatable(self,Page)
  return self
end


---Creates a new row for elements to get inserted into.
---@param name string?
function Page:newRow(name)
  local row = {
    label = name or "",
    content = {}
  }
  self.rows[#self.rows+1] = row
end


---@param data {label:string,text:string?,onClick:fun()?,isToggle:boolean?}
function Page:newButton(data)
  if data.label then self:newRow(data.label) end
  if not self.rows[1] then self:newRow() end
  
  local btn = {
    text = data.text,
    onClick = data.onClick,
    isToggle = data.isToggle,
    type = "Button"
  }
  local row = self.rows[#self.rows]
  row.content[#row.content+1] = btn
end

---@param data {label:string?,selected:integer?,texts:string[],onClick:fun(index:integer)?}
function Page:newRadioButton(data)
  if data.label then self:newRow(data.label) end
  if not self.rows[1] then self:newRow() end
  
  local btn = {
    selected = data.selected or 1,
    texts = data.texts,
    onClick = data.onClick,
    type = "RadioButton"
  }
  local row = self.rows[#self.rows]
  row.content[#row.content+1] = btn
end

---@param data {label:string,onChange:fun()?,min:number?,max:number?,step:number?,value:number?}
function Page:newSlider(data)
  if data.label then self:newRow(data.label) end
  if not self.rows[1] then self:newRow() end
  
  local btn = {
    onChange = data.onChange,
    type = "Slider",
    min = math.min(data.min or 0,data.max or 10),
    max = math.max(data.min or 0,data.max or 10),
    step = data.step or 1,
  }
  btn.value = data.value or btn.min
  local row = self.rows[#self.rows]
  row.content[#row.content+1] = btn
end


---@param data {label:string?,onConfirm:fun(field:string)?,onChange:fun(field:string)?,textField:string?}
function Page:newTextField(data)
  if data.label then self:newRow(data.label) end
  if not self.rows[1] then self:newRow() end
  local btn = {
    onConfirm = data.onConfirm,
    onChange = data.onChange,
    textField = data.textField,
    type = "TextField"
  }
  local row = self.rows[#self.rows]
  row.content[#row.content+1] = btn
end


-->========================================[ Dialog ]=========================================<--


---@class GNUI.Dialog
---@field page GNUI.Dialog.Page
---@field box GNUI.Box
---@field clientArea GNUI.Box
---@field titlebar GNUI.Box
local Dialog = {}
Dialog.__type = "GNUI.Dialog"
Dialog.__index = Dialog


---@param parent GNUI.any
---@return GNUI.Dialog
function Dialog.new(parent)
  local self = {
    box = GNUI.newBox(parent),
    rows = {}
  }
  self.clientArea = GNUI.newBox(self.box)
  self.titlebar = GNUI.newBox(self.box)
  setmetatable(self,Dialog)
  Theme.style(self,"Default")
  return self
end


---@param page GNUI.Dialog.Page
---@return GNUI.Dialog
function Dialog:setPage(page)
  ---@cast self GNUI.Dialog
  self.page = page
  -- Delete UI
  self.clientArea:purgeAllChildren()
  
  -- Generate UI
  for i = 1, #page.rows, 1 do
    local row = page.rows[i]
    
    local boxRow = GNUI.newBox(self.clientArea)
    :setAnchor(0,0,1,0)
    :setDimensions(4,(i-1)*14,0,i*14)
    :setText(row.label)
    :setTextAlign(0,1)
    :setChildrenOffset(0,1)
    :setZMul(i*10) -- sort by height
    
    local elementsBox = GNUI.newBox(boxRow)
    :setAnchor(0.5,0,1,1):setDimensions(0,0,-2,0)
    
    local contentCount = #row.content
    for c = 1, contentCount, 1 do
      local data = row.content[c]
      local elementBox = GNUI.newBox(elementsBox)
      :setAnchor((c-1)/contentCount,0,c/contentCount,1)
      
      local type = data.type
      if type == "Button" then -->==========[ Button ]==========<--
        Button.new(elementBox)
        :setAnchor(0,0,1,1)
        :setText(data.text)
        if data.onClick then Button.PRESSED:register(data.onClick) end
      
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
        local btn = Slider.new(false,data.min,data.max,data.step,data.value,elementsBox)
        :setAnchor(0,0,1,1)
        if data.onChange then btn.VALUE_CHANGED:register(function () data.onChange(btn.value) end) end
      elseif type == "TextField" then -->==========[ TextField ]==========<--
        local btn = TextField.new(elementBox)
        :setAnchor(0,0,1,1)
        :setText(data.textField)
        if data.onConfirm then btn.FIELD_CONFIRMED:register(data.onConfirm) end
        if data.onChange then btn.FIELD_CHANGED:register(data.onChange) end
      end
    end
    if self.page then
      self.box:setCustomMinimumSize(0,(#self.page.rows+1.2)*14)
    end
  end
  
  return self
end

-->========================================[ API ]=========================================<--

local api = {}

api.newDialog = Dialog.new
api.newPage = Page.new

return api