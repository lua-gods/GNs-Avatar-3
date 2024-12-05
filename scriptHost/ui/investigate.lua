local Pages = require"lib.pages"
local page = Pages.newPage("investigate",{bgOpacity=0,unlockCursor=false})

local use = keybinds:fromVanilla("key.playerlist")
use.press = function ()
   if Pages.currentPage == "default" then
      Pages.setPage("investigate")
   end
end
use.release = function ()
   if Pages.currentPage == "investigate" then
      Pages.returnPage()
   end
end
