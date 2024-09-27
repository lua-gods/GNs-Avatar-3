
local colors = {
  vectors.hexToRGB("#edab50"),
  vectors.hexToRGB("#e07438"),
  vectors.hexToRGB("#c64524"),
  vectors.hexToRGB("#8e251d"),
}



function pings.GNPOOF(x,y,z,appear)
  local pos = vec(x,y,z)
  particles:newParticle("minecraft:flash",pos):setColor(colors[1])
  local max_pow = 0.5
  for ci = 1, #colors, 1 do
    local clr = colors[ci]
    local low_pow,high_pow = (ci-1) / #colors * max_pow,ci / #colors * max_pow
    for i = 1, 200, 1 do
      local mpow = math.lerp(low_pow,high_pow,math.random())
      local inv_pow = math.pow((1 - mpow )* max_pow,3)
      local v = vectors.angleToDir(math.random()*360,math.random()*180)*mpow
      v:mul(1,1,1)
      local p = particles
      :newParticle("minecraft:end_rod",pos)
      if not appear then
        p:setVelocity(v)
        :color(clr)
        :lifetime(math.pow((1 - mpow )* max_pow,2) * 300)
        :gravity(-10*(inv_pow))
      else
        p:pos(pos+v*10)
        p:setVelocity(-v)
        :color(clr)
        :lifetime(math.pow((1 - mpow )* max_pow,2) * 300)
        :gravity(0)
      end
    end
  end
  sounds:playSound("minecraft:entity.illusioner.cast_spell",pos,0.33,2)
  sounds:playSound("minecraft:entity.illusioner.cast_spell",pos,0.33,1)
  sounds:playSound("minecraft:entity.illusioner.cast_spell",pos,0.33,0.5)
  sounds:playSound("minecraft:entity.generic.extinguish_fire",pos,0.1,0.8)
  --sounds:playSound("minecraft:entity.allay.item_taken",pos,1,0.5)
  for i = 1, 3, 1 do
    sounds:playSound("minecraft:particle.soul_escape",pos,1,1)
  end
  sounds:playSound("minecraft:entity.ghast.shoot",pos,0.2,.75)
end

if not host:isHost() then return end

local last_gamemode = nil

events.TICK:register(function ()
  local gamemode = player:getGamemode()
  if last_gamemode and last_gamemode ~= gamemode and (gamemode == "SPECTATOR" or last_gamemode == "SPECTATOR") then
    local pos = player:getPos():add(0,1,0)
    pings.GNPOOF(pos.x,pos.y,pos.z,gamemode ~= "SPECTATOR")
  end
  last_gamemode = gamemode
end)