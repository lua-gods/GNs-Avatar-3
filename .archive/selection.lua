local lastBlockPos = vec(0,0,0)
local lastTime = client:getSystemTime()
events.TICK:register(function ()
  local time = client:getSystemTime()
  local block = player:getTargetedBlock()
  local blockPos = block:getPos()
  if blockPos ~= lastBlockPos then
    lastBlockPos = blockPos
    lastTime = time
  end
  renderer:setBlockOutlineColor(1,1,1,math.clamp(200/(time - lastTime) * 0.5,0,0.5))
end)