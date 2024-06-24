local theme = require("libraries.gnui_extras.theme")
local api = {}

local button = require("libraries.gnui_extras.button")
local stack = require("libraries.gnui_extras.stack")

api.newButton = button.new
api.newStack = stack.new

return api