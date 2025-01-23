local key = keybinds:newKeybind("burb","key.keyboard.f")

key.press = function()
	if player:isLoaded() then
		pings.burp((-player:getRot().x+90)/200 + 0.7)
	end
end

local sound
function pings.burp(pitch)
	if player:isLoaded() then
		if sound then sound:stop() end
		sound = sounds["lore"]:volume(1):pos(player:getPos()):pitch(pitch):play()
	end
end

events.TICK:register(function ()
	if sound then
		sound:pitch((-player:getRot().x+90)/200 + 0.7)
	end
end)