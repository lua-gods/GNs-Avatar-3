-- Theme fallback handler

---@alias GNUI.Theme table<string,fun(box:GNUI.Box)>

local themePath
for _, path in pairs(listFiles("GNUI.theme")) do
  if path ~= "GNUI.theme" then themePath = path break end
end
local theme = themePath and require(themePath) or {}

return theme