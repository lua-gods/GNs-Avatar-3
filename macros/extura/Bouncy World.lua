local Macros = require("lib.macros")

local jump = keybinds:fromVanilla("key.jump")

return Macros.new("Bouncy World",function (events)
	local lvel = vec(0,0,0)
   function events.TICK()
		local vel = vec(table.unpack(player:getNbt().Motion))
		local accel = (vel - lvel)
		local fvel = lvel + accel * 2
		goofy:setVelocity(fvel)
		lvel = fvel
	end
end),"Makes everything bouncy"