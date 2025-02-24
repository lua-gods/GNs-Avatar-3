local Macros = require("scriptHost.macros")

local jump = keybinds:fromVanilla("key.jump")

return Macros.new("Bouncy World",function (events)
	local lvel = vec(0,0,0)
   function events.TICK()
		local vel = vec(table.unpack(player:getNbt().Motion))
		local accel = (vel - lvel)
		local fvel = lvel + accel * 2
		if accel:length() > 0.1 then
			goofy:setVelocity(fvel)
		end
		lvel = fvel
	end
end),"Makes everything bouncy"