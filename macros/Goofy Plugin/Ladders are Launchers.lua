local Macros = require("lib.macros")

local jump = keybinds:fromVanilla("key.jump")

return Macros.new("LaddersAreLaunchers",function (events)
	local lvel = vec(0,0,0)
   function events.TICK()
		local vel = vec(table.unpack(player:getNbt().Motion))
		if world.getBlockState(player:getPos()).id == "minecraft:ladder" and jump:isPressed() then
			goofy:setVelocity(vel + vec(0,1,0))
		end
	end
end),"Makes everything bouncy"