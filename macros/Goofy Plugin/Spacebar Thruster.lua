local Macros = require("lib.macros")

local jump = keybinds:fromVanilla("key.jump")

return Macros.new("Spacebar Jump",function (events)
   function events.TICK()
		if host:isHost() then
			if jump:isPressed() then
				goofy:setVelocity((vec(table.unpack(player:getNbt().Motion))*0.9):add(player:getLookDir()*0.2))
			end
		end
	end
end),"Holding the Jump button will make the player levitate"