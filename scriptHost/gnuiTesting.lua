--if true then return end
--- Require elements used
local GNUI = require "GNUI.main"
local Button = require "GNUI.element.button"

--- Create elements
local screen = GNUI.getScreenCanvas()

math.randomseed(8)

for i = 1, 10, 1 do
  local pos = vec(math.random(0,400),math.random(0,400))
  Button.new(screen):setPos(pos.x,pos.y):setSize(80,18):setText("Hello World")
end