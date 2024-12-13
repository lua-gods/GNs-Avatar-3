local use = keybinds:fromVanilla("key.use")
use:onPress(function ()
   if player:getHeldItem().id == "minecraft:air" then
      host:swingArm()
   end
end)