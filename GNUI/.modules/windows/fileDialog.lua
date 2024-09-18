
local cfg = require("GNUI.config")

local GNUI = require("GNUI.main")
local GNUIElements = require("GNUI.modules.elements")
local Window = require("GNUI.modules.windows.window")
local theme = require("GNUI.modules.themes")
local utils = require("GNUI.utils")
local eventLib = cfg.event


local PATH_PREFIX = "data://"
local LINE_HEIGHT = 15
local DOUBLE_CLICK_MS = 300

---@class GNUI.Window.FileManager : GNUI.Window
---@field TargetDirectory string
---@field ItemCount integer
---@field outliner GNUI.Container
---@field scrollbar GNUI.ScrollbarButton
---@field list GNUI.Container
---@field sidebar GNUI.Container
---@field ribbon GNUI.Container
---@field pathField GNUI.TextInputField
---@field undoButton GNUI.Button
---@field redoButton GNUI.Button
---@field upButton GNUI.Button
---@field downButton GNUI.Button
---@field filterButton GNUI.Button
---@field sortButton GNUI.Button
---@field bottomRibbon GNUI.Container
---@field fileNameField GNUI.TextInputField
---@field cancelButton GNUI.Button
---@field OptionsButton GNUI.Button
---@field FILE_SELECTED eventLib
---@field AcceptedSuffixes string[]
local FM = {}
FM.__index = function (t,i)
  return rawget(t,i) or FM[i] or Window[i] or GNUI.Container[i] or GNUI.Element[i]
end

FM.__type = "GNUI.Window.FileManager"


---@alias fileManagerType "OPEN"|"STANDARD"|"SAVE"

---@param screen GNUI.Container|GNUI.Canvas
---@param mode fileManagerType?
---@return GNUI.Window.FileManager
function FM.new(screen,mode)
  mode = mode or "STANDARD"
  ---@type GNUI.Window.FileManager
  local w = Window.new()
  w:setPos(16,16):setSize((screen.Dimensions.zw-screen.Dimensions.xy):sub(128,48))
  w:setSystemMinimumSize(128,64)
  w.TargetDirectory = ""
  w.FILE_SELECTED = eventLib.new()
  w.AcceptedSuffixes = {}
  setmetatable(w,FM)
  
  if mode == "STANDARD" then
    w:setTitle("File Explorer")
  elseif mode == "OPEN" then
    w:setTitle("File Dialog (Open a File)")
  elseif mode == "SAVE" then
    w:setTitle("File Dialog (Save a File)")
  end
  
  -->==========[ Outliner ]==========<--
  
  local outliner = GNUI.newContainer()
  --theme.applyTheme(outliner,"solid")
  outliner:setAnchor(0,0,1,1):setDimensions(65,18,-2,-19)
  w:addElement(outliner)
  w.outliner = outliner
  
  
  local scrollbar = GNUIElements.newScrollbarButton()
  scrollbar:setAnchor(1,0,1,1):setDimensions(-10,18,-2,-19):setRange(0,1)
  w:addElement(scrollbar)
  scrollbar.ON_SCROLL:register(function (scroll) 
    outliner:setChildrenShift(0,scroll * LINE_HEIGHT)
  end)
  ---@param event GNUI.InputEvent
  w.INPUT:register(function (event)
    if event.key == "key.mouse.scroll" then
      scrollbar.INPUT:invoke(event)
    end
  end)
  
  w.scrollbar = scrollbar
  
  local list = GNUIElements.newStack()
  list:setAnchor(0,0,1,1):setDimensions(0,0,-8,0)
  outliner:addChild(list)
  w.list = list
  
  -->==========[ Sidebar ]==========<--
  
  local sidebar = GNUI.newContainer()
  theme.applyTheme(sidebar,"solid")
  sidebar:setAnchor(0,0,0,1):setDimensions(2,18,66,-2)
  w:addElement(sidebar)
  w.sidebar = sidebar
  
  -->==========[ Ribbon ]==========<--
  local ribbon = GNUI.newContainer()
  ribbon:setAnchor(0,0,1,0):setDimensions(0,0,0,16)
  w:addElement(ribbon)
  w.ribbon = ribbon
  
  local pathField = GNUIElements.newTextInputField()
  pathField:setSize(-65-33,16):setPos(65,1):setAnchor(0,0,1,0)
  ribbon:addChild(pathField)
  w.pathField = pathField
  
  local undoButton = GNUIElements.newTextButton():setText("<-")
  undoButton:setSize(16,16):setPos(2,1)
  ribbon:addChild(undoButton)
  w.undoButton = undoButton
  
  local redoButton = GNUIElements.newTextButton():setText("->")
  redoButton:setSize(16,16):setPos(18,1)
  ribbon:addChild(redoButton)
  w.redoButton = redoButton
  
  local upButton = GNUIElements.newTextButton():setText("^")
  upButton:setSize(16,16):setPos(34,1)
  upButton.PRESSED:register(function ()
    w:setDirectory(w.TargetDirectory:sub(1,w.TargetDirectory:find("/[^/]+$") or 0))
  end)
  ribbon:addChild(upButton)
  w.upButton = upButton
  
  local reload = GNUIElements.newTextButton():setText("()")
  reload:setSize(16,16):setPos(50,1)
  ribbon:addChild(reload)
  reload.PRESSED:register(function ()
    w:refresh()
  end)
  w.downButton = reload
  
  local filterButton = GNUIElements.newTextButton():setText("F")
  filterButton:setSize(16,16):setPos(-34,1):setAnchor(1,0,1,0)
  ribbon:addChild(filterButton)
  w.filterButton = filterButton
  
  local sortByButton = GNUIElements.newTextButton():setText("S")
  sortByButton:setSize(16,16):setPos(-18,1):setAnchor(1,0,1,0)
  ribbon:addChild(sortByButton)
  w.sortByButton = sortByButton
  
  -->==========[ Bottom Ribbon ]==========<--
  
  local bottomRibbon = GNUI.newContainer()
  bottomRibbon:setAnchor(0,0,1,0):setDimensions(66,-20,0,0):setAnchor(0,1,1,1)
  w:addElement(bottomRibbon)
  w.bottomRibbon = bottomRibbon
  
  local fileNameField = GNUIElements.newTextInputField()
  fileNameField:setDimensions(2,2,-2,-2):setAnchor(0,0,1,1)
  bottomRibbon:addChild(fileNameField)
  w.fileNameField = fileNameField
  
  if mode ~= "STANDARD" then
    local cancelButton = GNUIElements.newTextButton():setText("Cancel")
    cancelButton:setDimensions(0,-34,0,-15):setAnchor(0,1,1,1)
    cancelButton.PRESSED:register(function () w:close() end)
    sidebar:addChild(cancelButton)
    w.cancelButton = cancelButton
    
    local okButton = GNUIElements.newTextButton()
    okButton:setDimensions(0,-18,0,0):setAnchor(0,1,1,1)
    sidebar:addChild(okButton)
    
    if mode == "SAVE" then
      okButton:setText("Save")
    elseif mode == "OPEN" then
      okButton:setText("Open")
    end
    
    okButton.PRESSED:register(function () 
      w:openFile(fileNameField.ConfirmedText)
    end)
    w.okButton = okButton
  end
  
  
  screen:addChild(w)
  w:refresh()
  w:updateScrollbar()
  w.DIMENSIONS_CHANGED:register(function ()
    w:updateScrollbar()
  end)
  local last_confirmed_path = PATH_PREFIX
  w.pathField.TEXT_CONFIRMED:register(function (text)
    local true_path = text:sub(#PATH_PREFIX+1,-1)
    if file:isDirectory(true_path) then
      last_confirmed_path = text
      w:setDirectory(true_path)
    else
      w:setDirectory(last_confirmed_path or "")
    end
  end)
  return w
end

function FM:setDirectory(dir)
  if file:isDirectory(dir) then
    self.TargetDirectory = dir
    self.fileNameField:setConfirmedText("",false)
    self:refresh()
  end
  return self
end


function FM:refresh()
  local dirs = file:list(self.TargetDirectory)
  self.outliner:purgeAllChildren()
  for i = 1, #dirs, 1 do
    local name = dirs[i]
    local path
    if #self.TargetDirectory > 1 then
      path = self.TargetDirectory .. "/" .. name
    else
      path = name
    end
    local isFile,isDirectory = file:isFile(path),file:isDirectory(path)
    local itemButton = GNUIElements.newTextButton("nothing"):setAnchor(0,0,1,0):setDimensions(1,(i-1)*LINE_HEIGHT,-7,i*LINE_HEIGHT):setText(name):setClipOnParent(true)
    theme.applyTheme(itemButton,"directory",nil,isFile,name:match("%.[/a-zA-Z]+$"))
    local last_click_time = 0
    itemButton.PRESSED:register(function ()
      local system_time = client:getSystemTime()
      if system_time-last_click_time < DOUBLE_CLICK_MS then
        if isDirectory then
          self:setDirectory(path)
        elseif isFile then
          self:openFile(name)
        end
      end
      if isFile then
        self.fileNameField:setConfirmedText(name,false)
      end
      last_click_time = system_time
    end)
    self.outliner:addChild(itemButton)
  end
  self.ItemCount = #dirs
  self.pathField:setConfirmedText(PATH_PREFIX..self.TargetDirectory,true)
  self:updateScrollbar()
  return self
end

function FM:updateScrollbar()
  self.scrollbar:setRange(0,(self.ItemCount+1) - self.outliner:getSize().y / LINE_HEIGHT)
  return self
end

function FM:openFile(name)
  local path = (#self.TargetDirectory > 0 and (self.TargetDirectory .. "/") or "") .. name
  if file:isFile(path) then
    local accepted = false
    if #self.AcceptedSuffixes == 0 then
      accepted = true
    else
      for key, value in pairs(self.AcceptedSuffixes) do
        if path:sub(-#value) == value then
          accepted = true
          break
        end
      end
    end
    if accepted then
      self.FILE_SELECTED:invoke(path)
      self:close()
    end
  end
end

--- Sets the accepted suffixes.
---@param suffixes string[]
function FM:setAcceptedSuffixes(suffixes)
  self.AcceptedSuffixes = suffixes or {}
  return self
end

return FM