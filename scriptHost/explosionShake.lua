local shake = 0

---@param value number
---@param seed number
---@param depth integer
---@param presistence number?
---@param lacunarity number?
---@return unknown
local function superSine(value,seed,depth,presistence,lacunarity)
   presistence = presistence or 0.5
   math.randomseed(seed)
   local max = 0 -- used to normalize the value
   local result = 0
   local w = 1
   local lun = 1 
   for _ = 1, depth, 1 do
      max = max + 1 * w
      result = result + math.sin(value * lun * (math.random() * math.pi * depth) + math.random() * math.pi * depth) * w
      lun = lun * (lacunarity or 1.5)
      w = w * (presistence or 0.75)
   end
   math.randomseed(client.getSystemTime())
   return result / depth / max
end

events.ON_PLAY_SOUND:register(function (id, pos, volume, pitch, loop, category, path)
   if id == "minecraft:entity.generic.explode" then
      shake = math.max(shake,90/(pos-client:getCameraPos()):length())
   end
end)

events.WORLD_RENDER:register(function ()
   local t = client:getSystemTime() / 500
   renderer:setOffsetCameraRot(
      superSine(t,123,10)* shake * 5,
      superSine(t,231,10)* shake * 5,
      superSine(t,133,10)* shake * 5)
   shake = shake * 0.95
end)