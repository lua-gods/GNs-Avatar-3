local Tween = require"lib.tween"
local GNUI = require("lib.GNUI.main")
local Theme = require"lib.GNUI.theme"

local Pages = require"lib.pages"
local Button = require"lib.GNUI.element.button"


local sidebarSize = 200


local page = Pages.newPage("pageEditor",0)
---@param screen GNUI.Box
page.INIT:register(function (screen)
   -->====================[ Context Menu ]====================<--
   local contextMenu = GNUI.newBox(screen)
   :setPos(0,0)
   :setSize(100,200)
   Theme.style(contextMenu,"Background")
   
   local persist = false
   
   ---@param event GNUI.InputEvent
   screen.INPUT:register(function (event)
      if event.key == "key.mouse.right" and event.state == 0 then
         local canvas = screen.Canvas
         local pos = canvas.MousePosition + vec(5,0)
         --pos.x = math.clamp(pos.x,0,contextMenu.Size.x)
         pos.y = math.clamp(pos.y,0,canvas.Size.y-contextMenu.Size.y)
         contextMenu:setPos(pos):setVisible(true)
      end
   end)
   
   contextMenu.MOUSE_PRESSENCE_CHANGED:register(function (hovering,pressed)
      if not hovering then
         contextMenu:setVisible(false)
      end
   end)
   
   -->====================[ Sidebar ]====================<--
   local toolbar = GNUI.newBox(screen)
   :setAnchor(1,0,1,1)
   :setSize(16,-8)
   Theme.style(toolbar,"Background")
   
   local sidebar = GNUI.newBox(screen)
   :setAnchor(1,0,1,1)
   
   Theme.style(sidebar,"Background")
   local sidebarButton = Button.new(screen)
   :setAnchor(1,0,1,1)
   
   local function updateSidebarSize()
      sidebar:setDimensions(-sidebarSize,0,0,0)
      sidebarButton:setDimensions(-2-sidebarSize,16,2-sidebarSize,-16)
      toolbar:setPos(-sidebarSize-20,4)
   end
   ---@param event GNUI.InputEventMouseMotion
   sidebarButton.MOUSE_MOVED:register(function (event)
      if sidebarButton.isPressed then
         sidebarSize = math.clamp(sidebarSize - event.relative.x,1,1000)
         updateSidebarSize()
      end
   end)
   
   
   local closeButton = Button.new(toolbar)
   :setSize(16,16)
   :setPos(0,-16)
   :setAnchor(0,1)
   :setTextOffset(0,-1)
   :setText("x")
   closeButton.PRESSED:register(function ()
      Pages.returnPage()
   end)
   
   updateSidebarSize()
end)