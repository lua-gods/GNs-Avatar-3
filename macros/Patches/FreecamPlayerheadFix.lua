local mat = matrices.mat4()
mat.v43 = -19

local Macros = require("lib.macros")


return Macros.new("Freecam Fix",function (macro)
	local lastActionBar = ""
	function macro.TICK()
		local actionBar = client:getActionbar()
		if actionBar ~= lastActionBar then
			lastActionBar = actionBar
			if actionBar then
				local component = parseJson(actionBar)
				if component.translate:sub(9,10)=="Fr" then
					renderer:setCameraMatrix(component.translate:sub(-4,-4) == "N" and mat or nil)
				end
			end
		end
	end
	function macro.EXIT()
		renderer:setCameraMatrix()
	end
end),"Shifts the clipping plane forward once freecam is detected from the action bar"