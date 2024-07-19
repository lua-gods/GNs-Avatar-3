local api = {}

local window = require("libraries.gnui.modules.windows.window")
local fileDialog = require("libraries.gnui.modules.windows.fileDialog")
api.Window = window
---@return GNUI.Window
function api.newWindow() return window.new() end

api.fileDialog = fileDialog
---@param screen GNUI.Container|GNUI.Canvas
---@param situation fileManagerType?
---@return GNUI.Window.FileManager
function api.newFileDialog(screen,situation)
   return fileDialog.new(screen,situation)
end

return api