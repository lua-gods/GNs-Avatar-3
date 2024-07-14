local api = {}

local button = require("libraries.gnui.modules.elements.button")
local stack = require("libraries.gnui.modules.elements.stack")
local text_button = require("libraries.gnui.modules.elements.text_button")

---@param variant string|"default"|"nothing"?
---@param theme string?
---@return GNUI.Button
api.newButton = function(variant,theme) return button.new(variant,theme) end
api.newStack = function() return stack.new() end

---@param variant string|"default"|"nothing"?
---@param theme string?
api.newTextButton = function(variant,theme) return text_button.new(variant,theme) end

api.Button = button
api.Stack = stack
api.TextButton = text_button
return api