---@alias GNUI.theme table<string,table<string,{variants:{default:fun(container:GNUI.any):GNUI.any}}>>

---@type GNUI.theme
local theme_library = {}

local search_path = ... .. ".themes"
for key, path in pairs(listFiles(... .. ".themes")) do
   local name = path:sub(#search_path + 2,-1):lower()
   theme_library[name] = require(path)
end

local api = {}

---Gets the theme for that element.
---@param element GNUI.any
---@param theme string?
---@param variant string?
function api.applyTheme(element,theme,variant)
   if not theme then theme = "default" end
   if not variant then variant = "default" end
   local type = element.__type:match("%.([^%.]+)$")
   theme_library[theme][type].variants[variant](element)
end

return api