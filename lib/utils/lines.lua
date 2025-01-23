local Lines = require"lib.line"

---@param mat Matrix4
function utils.lineDisplayMatrix(mat)
	local origin = mat:apply(0,0,0)
	Lines.new():setColor(1,0,0):setAB(origin,mat:apply(1,0,0))
	Lines.new():setColor(0,1,0):setAB(origin,mat:apply(0,1,0))
	Lines.new():setColor(0,0,1):setAB(origin,mat:apply(0,0,1))
end