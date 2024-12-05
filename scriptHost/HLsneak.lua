---@diagnostic disable: undefined-field
if not host.setPos then return end
local wasSneaking = false
events.TICK:register(function ()
   local isSneaking = player:isSneaking()
   if wasSneaking ~= isSneaking then
      wasSneaking = isSneaking
      if not player:isOnGround() then
         if isSneaking then
            host:setPos(player:getPos():add(0,0.5,0))
         else
            --host:setPos(player:getPos():add(0,-0.5,0))
         end
      end
   end
end)