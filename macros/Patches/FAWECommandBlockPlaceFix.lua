local Macros = require("scriptHost.macros")


return Macros.new("FAWECommandBlockPlace",function (macro)
	local lastActionBar = ""
	
	function macro.EXIT()
		renderer:setCameraMatrix()
	end
end),"places command block"