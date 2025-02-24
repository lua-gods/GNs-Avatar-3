local Macros = require("scriptHost.macros")

local blacklist = {
	"stair",
	"slab",
}

local use = keybinds:fromVanilla("key.use")


return Macros.new("AntiSit",function (events)
	use.press = function ()
		if player:getHeldItem().id:find("air$") then
			local block = player:getTargetedBlock(true,5)
			local match = false
			for key, entry in pairs(blacklist) do
				if block.id:find(entry) then
					match = true
					break
				end
			end
			return match
		end
	end
	
	function events.EXIT()
		use.press = nil
	end
end),"Disables interacting with stairs and slabs when holding nothing in hand, this is to prevent yourself from accidentally sitting on them"