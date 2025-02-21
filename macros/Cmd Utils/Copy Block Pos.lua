local Macros = require("lib.macros")

local c = keybinds:newKeybind("Ctrl","key.keyboard.c")

return Macros.new("CopyBlockPos",function (events)
	
   c.press = function ()
		local block = player:getTargetedBlock(true,10)
		if not block:isAir() then
			local pos = block:getPos()
			host:setClipboard(pos.x.." "..pos.y.." "..pos.z)
			host:setActionbar("Copied Block position to Clipboard")
		end
	end
	function events.EXIT()
		c.press = nil
	end
end),"Pressing [Ctrl] + [C] would copy the selected block's position"