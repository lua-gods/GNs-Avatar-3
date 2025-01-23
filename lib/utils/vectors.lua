---Returns the closest point on a line.
---@param pointPos Vector3
---@param linePos Vector3
---@param lineDir Vector3
---@return Vector3
function utils.closestPointOnLine(pointPos,linePos,lineDir)
	local dir = lineDir:normalized()
	local offset = pointPos - linePos
	local proj = offset:dot(dir)
	return linePos + proj * dir
end

---Returns the closest point on a axis.
---@param pointPos Vector3
---@param axisPos Vector3
---@param axisDir Vector3
---@return number
function utils.closestPointOnAxis(pointPos,axisPos,axisDir)
	local dir = axisDir:normalized()
	local offset = pointPos - axisPos
	return offset:dot(dir)
end

