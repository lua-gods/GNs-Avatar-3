local Line = require("lib.line")

-- creates a line
local test = Line.new()

test
:setA(vec(0,2,1)) -- sets the first end of the line
:setB(vec(0,5,2)) -- sets the second end of the line
:setColor(1,0,0) -- sets the color to red
:setWidth(0.25) -- sets the width to a quarter of a block