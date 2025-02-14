local Macros = require("lib.macros")

local POWER = 2

local contrl = keybinds:newKeybind("Ctrl","key.keyboard.left.control")
local c = keybinds:newKeybind("Ctrl","key.keyboard.c")

function pings.macroDash(dir)
	if not player:isLoaded() then return end
	local pos = player:getPos()
	local size = player:getBoundingBox()
	sounds:playSound("minecraft:entity.evoker.cast_spell",pos,1,1)
	sounds:playSound("minecraft:entity.illusioner.mirror_move",pos,1,1)
	sounds:playSound("minecraft:particle.soul_escape",pos,1,1)
	sounds:playSound("minecraft:particle.soul_escape",pos,1,0.5)
	
	for i = 1, 500, 1 do
		local ppos = pos + 
		vec(math.map(math.random(),-0.5,1.5,-size.x,size.x),
			math.map(math.random(),0,1,0,size.y),
			math.map(math.random(),-0.5,1.5,-size.z,size.z)
		)
		particles["end_rod"]:pos(ppos):spawn():velocity(dir*math.random()):lifetime(20)
	end
end

return Macros.new("CopyBlockPos",function (events)
	
   c.press = function ()
		local block = player:getTargetedBlock(true,10)
		if block:hasCollision() then
			local pos = block:getPos()
			host:setClipboard(pos.x.." "..pos.y.." "..pos.z)
			host:setActionbar("Copied Block position to Clipboard")
		end
	end
	function events.EXIT()
		c.press = nil
	end
end),"Pressing [Ctrl] + [C] would copy the selected block's position"