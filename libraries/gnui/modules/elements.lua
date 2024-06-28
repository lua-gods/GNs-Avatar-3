local theme = require("libraries.gnui.modules.themes")
local api = {}

local button = require("libraries.gnui.modules.elements.button")
local stack = require("libraries.gnui.modules.elements.stack")

api.newButton = button.new
api.newStack = stack.new

return api