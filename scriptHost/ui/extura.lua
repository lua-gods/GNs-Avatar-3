local GNUI = require("GNUI.main")

local Pages = require"libraries.pages"
local Button = require"GNUI.element.button"
local Slider = require"GNUI.element.slider"

GNUI.debugMode()
local page = Pages.newPage("extura")
---@param box GNUI.Box
page.INIT:register(function (box)
   local outliner = GNUI.newBox(box)
   :setAnchor(0,0,0.66,1)
end)