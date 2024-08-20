local pos
local rot
local died = false
macro.tick = function ()
   if player:getPermissionLevel() > 2 then
      if player:getHealth() == 0 then
         died = true
      else
         if died then
            host:sendChatCommand("/tp @s "..pos.x.." "..pos.y.." "..pos.z.." "..rot.y.." "..rot.x)
            died = false
         end
         pos = (player:getPos() * 100000):floor() / 100000
         rot = player:getRot():floor()
      end
   end
end
