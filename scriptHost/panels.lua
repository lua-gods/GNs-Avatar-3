local GNUI = require"GNUI.main"
local Theme = require"GNUI.theme"
local Button = require"GNUI.element.button"
local eventLib = require"libraries.eventLib"
local screen = GNUI.getScreenCanvas()
local icons = textures["textures.icons"]

local OFFSET = vec(0,-19)
local TABSIZE = 13
local BTNSIZE = 15

local base = GNUI.newBox(screen)
:setDimensions(92,0,0,0)
:setAnchor(0.5,0,1,1)


local tabsBox = GNUI.newBox(base):setAnchor(0,1)


local baseButton = Button.new(base)
:setSize(BTNSIZE,BTNSIZE):setPos(OFFSET)
:setAnchor(0,1,0,1)

--- Main Button Icon
local iconSize = 9/2
GNUI.newBox(baseButton)
:setNineslice(GNUI.newNineslice(icons,0,0,8,8))
:setAnchor(0.5,0.5)
:setDimensions(-iconSize,-iconSize,iconSize,iconSize)
:setBlockMouse(false)

local tabs = {}

local api = {}

---@param name string
---@param icon Nineslice
function api.newTab(name,icon)
  local btn = Button.new(tabsBox):setToggle(true)
  :setSize(TABSIZE,TABSIZE):setPos(0,(#tabs)*(TABSIZE-1))
  tabs[#tabs+1] = "FILLER"
  tabsBox:setDimensions(OFFSET.x+(BTNSIZE-TABSIZE)*0.5,-(#tabs*(TABSIZE-1))+OFFSET.y,OFFSET.x+BTNSIZE-(BTNSIZE-TABSIZE)*0.5,OFFSET.y)
end

return api