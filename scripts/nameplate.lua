--[[______  __           _            __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]
local config = {
  sync_wait_time = 20, -- ticks, second * 20 = ticks
}
local username = avatar:getEntityName()
local status

local defaultColors = {
  (vectors.hexToRGB("#e07438") * 255):floor(),
  (vectors.hexToRGB("#edab50 ") * 255):floor(),
  (vectors.hexToRGB("#e07438") * 255):floor(),
  (vectors.hexToRGB("#c64524") * 255):floor(),
}

local colors = defaultColors

-- Style
nameplate.ENTITY:setOutline(true):setBackgroundColor(0,0,0,0)

-->====================[ Mixing Styles ]====================<--

--- fallback of mix_gn_fancy wasnt working as wanted.
---@param clrA Vector3
---@param clrB Vector3
---@param i number
---@return Vector3
local function mixLinear(clrA,clrB,i)
---@diagnostic disable-next-line: return-type-mismatch
  return math.lerp(clrA,clrB,i)
end

---Mixes Multiple colors.
---@param i number
---@param subcolor table<any,Vector3>
---@return Vector3
local function multiMix(i,subcolor)
  i = i * (#subcolor-1) + 1
  return mixLinear(subcolor[math.floor(i)],subcolor[math.min(math.floor(i+1),#subcolor)],i%1) -- replace mix_gn_fancy with mix_linear
end

-->====================[ Rest ]====================<--


-- Generates a json text for minecraft to interpret as gradient text.
local function generateName()
  avatar:color(colors[1]/255)
  local final = {}
  final[#final+1] = {text="${badges}"} -- figura badge
  final[#final+1] = {text=":jack_o_lantern:"} -- figura badge
  --final[#final+1] = {font="figura:emoji_portrait",text=""} -- top hat
  for i = 1, #username, 1 do
    final[#final+1] = {
      text = username:sub(i,i),
      color = "#"..vectors.rgbToHex(multiMix(i/#username,colors)/255)
    }
  end
  nameplate.CHAT:setText(toJson(final))
  
  if status then
    final[#final+1] = {text="\nPlaying: "..status,color="gray"}
  end
  
  final = toJson(final)
  nameplate.LIST:setText(final)
  nameplate.ENTITY:setText(final)
  
end

function pings.syncName(name,...)
  colors = {...}
  generateName()
end


-- Host only things that will sync data to non host view of this avatar.
if not host:isHost() then return end
pings.syncName(username,table.unpack(colors))


-- every config.sync_wait_time, the timer triggers to sync the name to everyone
local timer = config.sync_wait_time
events.WORLD_TICK:register(function ()
  timer = timer - 1
  if timer < 0 then
    timer = config.sync_wait_time
    pings.syncName(username,table.unpack(colors))
  end
end)