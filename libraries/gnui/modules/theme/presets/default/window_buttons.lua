local gnui = require("libraries.gnui")
local texture = textures["libraries.gnui.modules.theme.textures.default_window"]

return {
   container = {
      ---@param container GNUI.button
      window = function (container)
         local sprite_normal = gnui.newSprite():setTexture(texture):setUV(23,1,25,10):setBorderThickness(1,8,1,1)
         local sprite_active = gnui.newSprite():setTexture(texture):setUV(27,1,29,10):setBorderThickness(1,8,1,1)
         container:setSprite(sprite_active)
      end
   },
   button = {
      ---@param container GNUI.button
      window_close = function (container)
         
         local sprite_normal = gnui.newSprite():setTexture(texture):setUV(14,1,20,7)
         local sprite_highlight = gnui.newSprite():setTexture(texture):setUV(14,9,20,15)
         
         container:setSprite(sprite_normal)
         container.MOUSE_PRESSENCE_CHANGED:register(function (hovered,pressed)
            if pressed then
               container:setSprite(sprite_normal)
            else
               if hovered then
                  container:setSprite(sprite_highlight)
               else 
                  container:setSprite(sprite_normal)
               end 
            end
         end)
         container.label:free()
         container:setAnchor(1,0,1,0):setDimensions(-8,1,-1,8)
      end,
      window_maximize = function (container)
         
         local sprite_normal = gnui.newSprite():setTexture(texture):setUV(8,1,14,7)
         local sprite_highlight = gnui.newSprite():setTexture(texture):setUV(8,9,14,15)
         
         container:setSprite(sprite_normal)
         container.MOUSE_PRESSENCE_CHANGED:register(function (hovered,pressed)
            if pressed then
               container:setSprite(sprite_normal)
            else
               if hovered then
                  container:setSprite(sprite_highlight)
               else 
                  container:setSprite(sprite_normal)
               end 
            end
         end)
         container.label:free()
         container:setAnchor(1,0,1,0):setDimensions(-15,1,-8,8)
      end,
      window_minimize = function (container)
         
         local sprite_normal = gnui.newSprite():setTexture(texture):setUV(1,1,7,7)
         local sprite_highlight = gnui.newSprite():setTexture(texture):setUV(1,9,7,15)
         
         container:setSprite(sprite_normal)
         container.MOUSE_PRESSENCE_CHANGED:register(function (hovered,pressed)
            if pressed then
               container:setSprite(sprite_normal)
            else
               if hovered then
                  container:setSprite(sprite_highlight)
               else 
                  container:setSprite(sprite_normal)
               end 
            end
         end)
         container.label:free()
         container:setAnchor(1,0,1,0):setDimensions(-22,1,-15,8)
      end,
   },
   
}