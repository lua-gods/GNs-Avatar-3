local Line = require("lib.line")

-- creates a line
local a = Line.new()
local b = Line.new()

a
:setA(vec(0,2,0))
:setB(vec(0,5,0))
:setWidth(1)
:setColor("#00FF00")

b
:setB(vec(0,2,0))
:setA(vec(0,2,5))
:setWidth(1)
:setColor("#FF0000")