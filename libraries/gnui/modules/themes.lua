---@alias GNUI.theme table<{variants:{default:fun(container:GNUI.any):GNUI.any}}>

---@type GNUI.theme
local theme_library = {}

for key, preset_path in pairs(listFiles(... .. ".theme.presets",true)) do
   local words = {}
   for word in preset_path:gmatch("[^%.]+") do
      words[#words+1] = word
   end
   if not theme_library[words[#words-1]] then -- create theme directory
      theme_library[words[#words-1]] = {}
   end
   theme_library[words[#words-1]][words[#words]] = require(preset_path) -- insert theme for element
end

local api = {}

---Gets the theme for that element.
---@param element GNUI.any
---@param theme string?
---@param variant string|"nothing"?
function api.applyTheme(element,theme,variant)
   if not theme then theme = "default" end
   if not variant then variant = "default" end
   if variant == "nothing" then return end
   local type = element.__type:match("%.([^%.]+)$")
   theme_library[theme][type][variant](element)
end

return api