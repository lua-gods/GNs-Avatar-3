local macro = require"scriptHost.macros"
return macro.new("eyealigner",function (events)
  function events.WORLD_RENDER(deltaFrame,deltaTick)
    if player:isLoaded() then
      local eye = player:getPos(deltaTick):add(0,player:getEyeHeight())
      local origin = client:getCameraPos()
      local dir = client:getCameraDir()
      local block,hitpos,side = raycast:block(origin,origin+dir*5,"OUTLINE","NONE")
      renderer:setEyeOffset(hitpos-eye+dir*0.01)
    end
  end
  function events.EXIT()
    renderer:setEyeOffset()
  end
end)