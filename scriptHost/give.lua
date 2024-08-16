---@diagnostic disable: lowercase-global
--- Give an item to the player.
---@param item string
function give(item)
   if player:isLoaded() then
      local id = player:getNbt().SelectedItemSlot
      sounds:playSound("minecraft:entity.item.pickup",client:getCameraPos():add(client:getCameraDir()),1,1)
      host:setSlot("hotbar."..id,item)
   end
end