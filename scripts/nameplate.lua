--[[______  __           _            __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]
local config = {
  sync_wait_time = 20*5, -- ticks, second * 20 = ticks
}
local endesga = require"lib.palettes.endesga64"
local username = avatar:getEntityName()

local Gradient = require("lib.gradient")

local plate = {
  name = avatar:getEntityName(),
  gradient = Gradient.new({
     [0] = endesga.lightGreen,
     [0.5] = endesga.brightGreen,
     [2] = endesga.lightGreen,
     [3] = endesga.darkGreen,
  }),
}

local cluster = {
  "^:.+:",
  "${.+}",
  ".",
}

nameplate.ENTITY:setOutline(true)
nameplate.ENTITY:setBackgroundColor(0,0,0,0)

local function makeNameplate()
  if plate.name == "" then
    return
  end
  
  local chars = {}
  
  do
    local name = plate.name:gsub("\\n","\n")
    local i = 1
    while i <= #name do
      for j = 1, #cluster, 1 do
        local start,to = name:find(cluster[j], i)
        if start then
          i = to
          chars[#chars + 1] = name:sub(start, to)
          break
        end
      end
      i = i + 1
    end
  end
  
  local baked = {}
  for i = 1, #chars, 1 do
    baked[i] = {
      text = chars[i],
      color = "#"..vectors.rgbToHex(plate.gradient:sampleRange((i-1)/#chars))
    }
  end
  nameplate.ALL:setText(toJson(baked))
end

plate.makeNameplate = makeNameplate

if IS_HOST then
  local function sync()
    pings.syncNameplate(plate.name,plate.gradient:pack())
  end
  local timer = 0
  events.WORLD_TICK:register(function ()
  timer = timer - 1
  if timer < 0 then sync() timer = 10 end
  end)
end
---@param name string
---@param gradient string
function pings.syncNameplate(name,gradient)
  plate.name = name
  plate.gradient = Gradient.new(gradient)
  makeNameplate()
end

return plate