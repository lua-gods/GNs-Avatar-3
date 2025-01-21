--[[______   __
  / ____/ | / / By: GNamimates | https://gnon.top | Discord: @gn8.
 / / __/  |/ / GN animation library
/ /_/ / /|  / State machines, blend drivers n stuff.
\____/_/ |_/ Source: https://github.com/lua-gods/GNs-Avatar-3/blob/main/lib/GNanim.lua]]
local config = {
	-- automatically interpolate the given weights, enable this if youre using values that are tick based
	autoInterpolate = true
}


local rootBlendDrivers = {}
local api = {}

---A blend state machine
---@class GNanim.mix
---@field from Animation|GNanim.mix
---@field to Animation|GNanim.mix
---@field parent GNanim.mix?
---
---@field weightDriver fun()?
---@field weight number # the transition from `from` to `to`
---@field weightStrength number # the strength of the overall from and to
---
---@field speedDriver fun()?
---@field speedMul number
---@field speedStrength number
local mix = {}
mix.__index = mix
mix.__type = "BlendDriver"


---@param from Animation|GNanim.mix
---@param to Animation|GNanim.mix
---@param weightDriver (fun():number|boolean)?
---@param speedDriver (fun():number|boolean)?
---@return GNanim.mix
function api.newBlend(from,to,weightDriver,speedDriver)
	local self = {
		from = from,
		to = to,
		weightDriver = weightDriver,
		speedDriver = speedDriver,
		weightStrength = 1,
		speedStrength = 1,
	}
	setmetatable(self,mix)
	rootBlendDrivers[self] = true
	if type(from) == "BlendDriver" then self.from:setParent(self)end
	if type(to) == "BlendDriver" then self.to:setParent(self)end
	return self
end


---@param parent GNanim.mix?
---@return GNanim.mix
function mix:setParent(parent)
	self.parent = parent
	rootBlendDrivers[self] = parent and nil or true
	return self
end


local function toWeight(input)
	local type = type(input)
	if type == "number" then
		return input
	elseif type == "boolean" then
		return input and 1 or 0
	end
end


---@return GNanim.mix
function mix:update()
	local weight = self.weightDriver and math.clamp(toWeight(self.weightDriver()),0,1) or 0
	local speed = (self.speedDriver and toWeight(self.speedDriver()) or 1) * self.speedStrength
	local strength = self.weightStrength
	if self.from then
		local final = (1-weight) * strength
		self.from:blend(final):speed(speed)
		
		local isFromPlaying = self.from:isPlaying()
		if final == 0 then if isFromPlaying then self.from:stop() end
		else if not isFromPlaying then self.from:play() end
		end
	end
	if self.to then
		local final = weight * strength
		self.to:blend(final):speed(speed)
		
		local isToPlaying = self.to:isPlaying()
		if final == 0 then if isToPlaying then self.to:stop() end
		else if not isToPlaying then self.to:play() end
		end
	end
	self.speedMul = speed
	self.weight = weight
	return self
end


---@param strength number
---@return GNanim.mix
function mix:blend(strength)
	self.lastStrength = self.weightStrength
	self.weightStrength = strength
	self:update()
	return self
end


---@return GNanim.mix
function mix:play()
	if self.from then self.from:play() end
	if self.to then self.to:play() end
	return self
end


---@return GNanim.mix
function mix:stop()
	if self.from then self.from:stop() end
	if self.to then self.to:stop() end
	return self
end


function mix:isPlaying()
	return self.weightStrength > 0
end


---@param strength number
function mix:speed(strength)
	self.speedStrength = strength
	return self
end

local drivers = {}
local smoothBool = {}

local lastSystemTime = client:getSystemTime()
events.RENDER:register(function (_, ctx)
	if ctx == "RENDER" then
		local systemTime = client:getSystemTime()
		local deltaFrame = (systemTime - lastSystemTime) / 1000
		lastSystemTime = systemTime
		
		for bool, data in pairs(smoothBool) do 
			local drive = data.driver()
			data.time = math.clamp(data.time + deltaFrame * (type(drive) == "number" and drive or (drive and 1 or -1)),0,data.duration)
		end
		for blendDrivers in pairs(rootBlendDrivers) do blendDrivers:update()end
		for animation, driver in pairs(drivers) do driver(animation)end
	end
end)

---Creates a driver for the animation, can be used as a replacement to animation inputs
---@param animation Animation
---@param driver fun(animation:Animation)
function api.newDriver(animation,driver)
	drivers[animation] = driver
	return animation
end

---Converts a boolean into a smooth number from 0 to 1, can be a replacement to weight/speed inputs
---@param driver fun():boolean|number
---@param duration number
---@param start boolean?
function api.smooth(driver,duration,start)
	local data = {driver = driver,duration = duration,time = start and duration or 0}
	smoothBool[driver] = data
	local proxy = function ()
		return data.time / data.duration
	end
	
	return proxy
end



---@param animation Animation
---@param afterAnimation Animation
function api.playAfter(animation,afterAnimation)
	local played = false
	local uuid = client.intUUIDToString(client:generateUUID())
	events.WORLD_RENDER:register(function (delta)
		if played then
			if animation:getPlayState() ~= "PLAYING" then
				animation:stop()
				afterAnimation:stop():play()
				events.WORLD_RENDER:remove(uuid)
			end
		else
			if animation:getPlayState() == "PLAYING" then
				played = true
			end
		end
	end,uuid)
end

return api
