local died = true
events.TICK:register(function ()
  if player:getHealth() == 0 then
    if not died then
      died = true
      sounds["death"]:pos(player:getPos()):play()
    end
  else
    if died then
      died = false
    end
  end
end)