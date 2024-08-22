local api = {}

local cfg = require("GNUI.config")

local window = require("GNUI.modules.windows.window")
local fileDialog = require("GNUI.modules.windows.fileDialog")
api.Window = window
---@param manualClosing boolean?
---@return GNUI.Window
function api.newWindow(manualClosing) return window.new(manualClosing,false) end

api.fileDialog = fileDialog
---@param screen GNUI.Container|GNUI.Canvas
---@param situation fileManagerType?
---@return GNUI.Window.FileManager
function api.newFileDialog(screen,situation)
   return fileDialog.new(screen,situation)
end

return api