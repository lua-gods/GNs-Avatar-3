local Macros = require("lib.macros")

local blacklist = {
	"stair",
	"slab",
}

local use = keybinds:fromVanilla("key.use")

return Macros.new("RightClickMakesArmSwing",function (events)
	use.press = function ()
		if player:getHeldItem().id == "minecraft:air" then
			host:swingArm()
		end
	end
	
	function events.EXIT()
		use.press = nil
	end
end),"Disables interacting with stairs and slabs when holding nothing in hand, this is to prevent yourself from accidentally sitting on them"