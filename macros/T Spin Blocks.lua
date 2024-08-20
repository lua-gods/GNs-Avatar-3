local side2dir = {
   north = vec(0,0,-1),
   east = vec(1,0,0),
   south = vec(0,0,1),
   west = vec(-1,0,0),
   up = vec(0,1,0),
   down = vec(0,-1,0)
}
local dir2side = {
   [tostring(vec(0,0,-1))] = "north",
   [tostring(vec(1,0,0))] = "east",
   [tostring(vec(0,0,1))] = "south",
   [tostring(vec(-1,0,0))] = "west",
   [tostring(vec(0,1,0))] = "up",
   [tostring(vec(0,-1,0))] = "down"
}

local interacted = false
local interact = keybinds:fromVanilla("key.use")
interact.press = function ()
   interacted = true
end

macro.tick = function ()
   if interacted then
      interacted = false
      if player:isSneaking() then
         if player:getHeldItem().id == "minecraft:golden_hoe" and player:getPermissionLevel() >= 2 then
            local block, hitPos, side = player:getTargetedBlock()
            if block.properties.facing then
               local new = vectors.rotateAroundAxis(-90,side2dir[block.properties.facing],side2dir[side])
               new.x = math.floor(new.x + 0.5)
               new.y = math.floor(new.y + 0.5)
               new.z = math.floor(new.z + 0.5)
               local p = block:getPos()
               local property = ""
               for key, value in pairs(block.properties) do
                  if key == "facing" then value = dir2side[tostring(new)] end
                  property = property..key.."="..value..","
               end
               property = "["..property:sub(1,-2).."]"
               host:swingArm()
               local ok = pcall(world.newBlock,block.id..property)
               if ok and block.properties.facing ~= dir2side[tostring(new)] then
                  local e = block:getEntityData() or {}
                  e.OutputSignal = nil
                  e = #tostring(printTable(e,0,true)) > 15
                  if e then
                     host:sendChatCommand("/data modify storage gn:storage storage set value '1'")
                     host:sendChatCommand(("/data modify storage gn:storage storage set from block %i %i %i"):format(p.x,p.y,p.z,block.id..property))
                     host:sendChatCommand(("/data modify block %i %i %i {} merge from storage gn:storage storage"):format(p.x,p.y,p.z))
                  end
                  host:sendChatCommand(("/setblock %i %i %i %s"):format(p.x,p.y,p.z,block.id..property))
                  if e then
                     host:sendChatCommand(("/data modify block %i %i %i {} merge from storage gn:storage storage"):format(p.x,p.y,p.z))
                  end
                  host:sendChatCommand(("/playsound minecraft:block.wooden_trapdoor.open master @a %i %i %i"):format(p.x,p.y,p.z))
               end
            end
         end
      end
   end
end
