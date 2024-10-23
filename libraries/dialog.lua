local GNUI = require"GNUI.main"
local Theme = require"GNUI.theme"
local Button = require"GNUI.element.button"
local eventLib = require"libraries.eventLib"
local screen = GNUI.getScreenCanvas()


-->========================================[ Page ]=========================================<--

---@alias GNUI.Dialog.any GNUI.Dialog.Button|GNUI.Dialog.RadioButton

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
---@field onClick fun(index: integer)

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
    :setZMul(i) -- sort by height
    
    local elementBox = GNUI.newBox(boxRow)
    :setAnchor(0.5,0,1,1):setDimensions(0,0,-2,0)
    
    local contentCount = #row.content
    for c = 1, contentCount, 1 do
      local content = row.content[c]
      local a,b = (c-1)/contentCount,c/contentCount
      
      local type = content.type
      if type == "Button" then
        Button.new(elementBox)
        :setAnchor(a,0,b,1)
        :setText(content.text)
      
      elseif type == "RadioButton" then
        local buttons = {} ---@type GNUI.Button[]
        local function renew()
          for j = 1, #buttons, 1 do
            local button = buttons[j]
            if content.selected == j then
              if not button.isPressed then button:press() end
            else
              if button.isPressed then button:press() end
            end
          end
        end
        for j = 1, #content.texts, 1 do
          local button = Button.new(elementBox):setToggle(true)
          :setAnchor(math.lerp(a,b,(j-1)/#content.texts),0,math.lerp(a,b,j/#content.texts),1)
          :setText(content.texts[j])
          local o = j
          button.BUTTON_DOWN:register(function ()
            content.selected = o
            renew()
          end)
          button.BUTTON_UP:register(renew)
          renew()
          buttons[j] = button
        end
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