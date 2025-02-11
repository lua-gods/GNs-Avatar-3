local Macros = require("lib.macros")

local forward = keybinds:fromVanilla("key.forward")

local enabled = false
local throttle = 0
local sthrottle = 0
function pings.throttle(toggle,throt)
		throttle = throt
		enabled = toggle
end

local function pitch(value)
	
	for i = 1, 10, 1 do
		if value > 0.5 then
			value = value / 2
		end
	end
	return value
end

return Macros.new("VroomVroom",function (events)
	local engine = sounds["engine"]:play():loop(true)
   function events.TICK()
		local vel = vec(table.unpack(player:getNbt().Motion))
		if host:isHost() then
			if player:isOnGround() then
				goofy:setVelocity(vel+player:getLookDir():mul(1,0,1):normalize()*throttle * 0.3)
			end
			sthrottle = math.lerp(sthrottle,pitch(throttle),0.3)
			if enabled ~= forward:isPressed() then
				enabled = forward:isPressed()
				pings.throttle(enabled,throttle)
			end
		end
		engine:setPitch(0.75+sthrottle*3)
		if player:isLoaded() then
			engine:pos(player:getPos())
		end
		if enabled then
			throttle = throttle + 0.01
		else
			throttle = throttle * 0.9
		end
	end
	
	function events.EXIT()
		engine:stop()
	end
end,true),"???"