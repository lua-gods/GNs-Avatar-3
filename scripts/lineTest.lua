local Line = require("lib.line")

-- creates a line
local a = Line.new()
local b = Line.new()

a
:setA(vec(0,2,0)) -- sets the first end of the line
:setB(vec(0,5,0)) -- sets the second end of the line
:setWidth(1)
:setColor("#00FF00")

b
:setB(vec(1,2,0)) -- sets the first end of the line
:setA(vec(1,5,0)) -- sets the second end of the line
:setWidth(1)
:setColor("#FF0000")