local gnui = require("libraries.gnui")

local texture = textures["textures.icons"]

return {
   button = {
      ---@param container GNUI.button
      toggle_chat = function (container)
         local sprite_idle = gnui.newSprite():setTexture(texture):setUV(1,1,13,13)
         local sprite_alert = gnui.newSprite():setTexture(texture):setUV(15,1,27,13)
         
         container.MOUSE_PRESSENCE_CHANGED:register(function (hovered,pressed)
            if pressed then
               sprite_idle:setColor(0.5,0.5,0.5)
            else
               if hovered then
                  sprite_idle:setColor(1,1,1)
               else
                  sprite_idle:setColor(0.9,0.9,0.9)
               end
            end
         end)
         
         container:setSprite(sprite_idle)
         container.PRESSED:register(function ()
            container:setSprite(sprite_idle)
         end)
         events.CHAT_RECEIVE_MESSAGE:register(function ()
            container:setSprite(sprite_alert)
         end)
      end
   }
}
