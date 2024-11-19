local GNUI = require("lib.GNUI.main")

local Pages = require"lib.pages"
local Button = require"lib.GNUI.element.button"
local Slider = require"lib.GNUI.element.slider"

--GNUI.debugMode()
local page = Pages.newPage("extura")
---@param box GNUI.Box
page.INIT:register(function (box)
   local outliner = GNUI.newBox(box)
   :setAnchor(0,0,0.66,1)
   
   local list = listFiles("macros.extura")
   for i, path in pairs(list) do
      local macro = require(path) ---@type Macro
      local row = GNUI.newBox(outliner)
      :setAnchor(0,0,1,0)
      :setSize(0,20)
      :setPos(0,(i)*20)
      :setText(macro.name)
      :setTextAlign(0,0.5)
      :setTextOffset(5,1)
      
      config:setName("GN.Macros")
      --config:load("")
      
      local toggleButton = Button.new(row)
      :setAnchor(0.5,0,0.5,1)
      :setDimensions(-40,0,40,0)
      :setText("Enabled")
      local keybindButton = Button.new(row)
      :setAnchor(0.5,0,1,1)
      :setDimensions(40,0,0,0)
   end
end)