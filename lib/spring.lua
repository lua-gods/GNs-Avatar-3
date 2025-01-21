-- 2nd-order system library
-- source: https://www.youtube.com/watch?v=KPoeNZZ6H4

---@class Spring
---@field id integer
---@field pos number
---@field lpos number
---@field accel number
---@field target number
---@field ltarget number
---@field f number
---@field z number
---@field r number
local Spring = {}
Spring.__index = Spring

local springs = {}

local TAU = math.pi*2
local PI = math.pi

---@param cfg {pos?: number, vel?: number,f?: number,z?: number,r?: number}
function Spring.new(cfg)
	local id = #springs + 1
	local s = {
		pos = cfg.pos or 0,
		vel = cfg.vel or 0,
		f = cfg.f or 1,
		z = cfg.z or 0.05,
		r = cfg.r or 0,
		target = 0,
		ltarget = 0,
		accel = 0,
	}
	-- compute constraints
	s.k1 = s.z / (PI * s.f)
	s.k2 = 1 / ((2 * PI * s.f) * (TAU * s.f))
	s.k3 = s.r * s.z / (TAU * s.f)
	
	setmetatable(s, Spring)
	springs[id] = s
	return s
end



function Spring.update(t)
	t = math.min(t, 0.1)
	for i, s in pairs(springs) do
		local taccel = 0
		if not s.ltarget then taccel = (s.target - s.ltarget) / t end
		s.ltarget = s.target
		
		s.pos = s.pos + t * s.vel
		s.vel = s.vel + t * (s.target + s.k3*taccel - s.pos - s.k1*s.vel - s.k1*s.vel) / s.k2
		
		s = s.next
	end
end

function Spring:free()
	springs[self.id] = nil
end

return Spring