local active = false
local key = keybinds:newKeybind("California","key.keyboard.j")

key.press = function() pings.california(not active) end

local music

local function process()
	music:pos(player:getPos())
end

function pings.california(toggle)
	active = toggle
	if toggle then
		music = sounds["californ"]:play():loop(true)
		events.TICK:register(process)
		animations.player.california:play()
	else
		animations.player.california:stop()
		music:stop()
		events.TICK:remove(process)
	end
end