local lastTitle = ""
local window = require("GNUI.modules.windows")
window.Window.ACTIVE_WINDOW_CHANGED:register(function (a,b)
   if (a and not a.isPopup) or (not a) then
      local title = a and a.Title
      if lastTitle ~= title then
         setStatus(title)
         lastTitle = title
      end
   end
end)