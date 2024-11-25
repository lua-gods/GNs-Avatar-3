local GNUI = require("lib.GNUI.main")

local Pages = require"lib.pages"
local Button = require"lib.GNUI.element.button"

local page = Pages.newPage("nameplate")
---@param screen GNUI.Box
page.INIT:register(function (screen)
   local closeButton = Button.new(screen)
   :setSize(18,18)
   :setPos(40,40)
   :setText("X")
   .PRESSED:register(function ()
      Pages.returnPage()
   end)
end)