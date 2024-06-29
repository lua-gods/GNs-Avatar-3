local api = {}

local window = require("libraries.gnui.modules.windows.window")

function api.newWindow()
   return window.new()
end

return api