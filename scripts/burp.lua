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
		sound = sounds.burp:volume(0.25):pos(player:getPos()):pitch(pitch):play()
	end
end