local theme = require("libraries.gnui.modules.themes")
local api = {}

local button = require("libraries.gnui.modules.elements.button")
local stack = require("libraries.gnui.modules.elements.stack")

---@param variant string|"default"|"nothing"?
---@return GNUI.button
api.newButton = function(variant) return button.new(variant) end
api.newStack = function() return stack.new() end

api.button = button
api.stack = stack

return api