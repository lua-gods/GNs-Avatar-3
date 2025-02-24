local macro = require"scriptHost.macros"
return macro.new("sync particles",function (events)
  function events.TICK()
    if player:isLoaded() then
      particles["end_rod"]:pos(player:getPos():add(0,3,0)):spawn()
    end
  end
end,true)