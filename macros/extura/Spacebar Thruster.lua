local Macros = require("lib.macros")

local jump = keybinds:fromVanilla("key.jump")

return Macros.new("Extura Web",function (events)
   function events.TICK()
		if host:isHost() then
			if jump:isPressed() then
				goofy:setVelocity(vec(table.unpack(player:getNbt().Motion)):add(0,0.1,0))
			end
		end
	end
end),"Holding the Jump button will make the player levitate"