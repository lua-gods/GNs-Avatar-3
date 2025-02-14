--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / makes it easy to call a function many times until it returns true
/ /_/ / /|  / can sleep
\____/_/ |_/ Source: hello]]
local queries = {}
local processor

local MAX_QUERIES = 1000

local function setProcessActive(isActive)
	events.WORLD_RENDER[isActive and "register" or "remove"](events.WORLD_RENDER,processor)
end

processor = function ()
	local time = client:getSystemTime()
	for key, query in pairs(queries) do
		for _ = 1, math.max(queries[1].repeatCount,1), 1 do
			if queries[1].process() then
				if query.onFinish then
					query.onFinish()
				end
				queries[key] = nil
				if #queries == 0 then setProcessActive(false) return end
				break
			end
		end
	end
end

---Repeats a process until it returns true
---@param process function
---@param repeatCount integer?
---@param onFinish function?
function _G.repeatUntiltrue(process,repeatCount,onFinish)
	queries[#queries+1] = {repeatCount=repeatCount,process=process,onFinish=onFinish}
	if #queries == 1 then setProcessActive(true) end
end