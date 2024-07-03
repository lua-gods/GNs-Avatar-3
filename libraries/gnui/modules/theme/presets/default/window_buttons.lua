local gnui = require("libraries.gnui")
local texture = textures["libraries.gnui.modules.theme.textures.default_window"]

return {
   window = {
      ---@param container GNUI.window
      default = function (container)
         local sprite_border_normal = gnui.newSprite():setTexture(texture):setUV(23,1,25,10):setBorderThickness(1,8,1,1)
         local sprite_border_active = gnui.newSprite():setTexture(texture):setUV(1,23,5,27):setBorderThickness(2,2,2,2)
         container:setSprite(sprite_border_active)
         
         local sprite_titlebar_normal = gnui.newSprite():setTexture(texture):setUV(23,1,25,10):setBorderThickness(1,8,1,1)
         local sprite_titlebar_active = gnui.newSprite():setTexture(texture):setUV(1,17,5,21):setBorderThickness(2,2,2,2)
         container.Titlebar:setSprite(sprite_titlebar_active)
         container.Titlebar:setAnchor(0,0,1,0):setDimensions(1,1,-1,12)
         
         container.LabelTitle:setDefaultColor("#1e6f50")
         :setText("Unknown")
         :setAnchor(0,0,1,1):setDimensions(2,2,-2,-2)
         
         
         local close_button = container.CloseButton
         local sprite_close_normal = gnui.newSprite():setTexture(texture):setUV(14,1,20,7)
         local sprite_close_highlight = gnui.newSprite():setTexture(texture):setUV(14,9,20,15)
         close_button:setSprite(sprite_close_normal)
         close_button.MOUSE_PRESSENCE_CHANGED:register(function (hovered,pressed)
            if pressed then
               close_button:setSprite(sprite_close_normal)
            else
               if hovered then
                  close_button:setSprite(sprite_close_highlight)
               else 
                  close_button:setSprite(sprite_close_normal)
               end 
            end
         end)
         close_button.label:free()
         close_button:setAnchor(1,0,1,0):setDimensions(-10,3,-3,10)
         
         local maximize_button = container.MaximizeButton
         local sprite_maximize_normal = gnui.newSprite():setTexture(texture):setUV(8,1,14,7)
         local sprite_maximize_highlight = gnui.newSprite():setTexture(texture):setUV(8,9,14,15)
         
         maximize_button:setSprite(sprite_maximize_normal)
         maximize_button.MOUSE_PRESSENCE_CHANGED:register(function (hovered,pressed)
            if pressed then
               maximize_button:setSprite(sprite_maximize_normal)
            else
               if hovered then
                  maximize_button:setSprite(sprite_maximize_highlight)
               else 
                  maximize_button:setSprite(sprite_maximize_normal)
               end 
            end
         end)
         maximize_button.label:free()
         maximize_button:setAnchor(1,0,1,0):setDimensions(-17,3,-10,10)
         
         local sprite_normal = gnui.newSprite():setTexture(texture):setUV(1,1,7,7)
         local sprite_highlight = gnui.newSprite():setTexture(texture):setUV(1,9,7,15)
         
         local minimize_button = container.MinimizeButton
         minimize_button:setSprite(sprite_normal)
         minimize_button.MOUSE_PRESSENCE_CHANGED:register(function (hovered,pressed)
            if pressed then
               minimize_button:setSprite(sprite_normal)
            else
               if hovered then
                  minimize_button:setSprite(sprite_highlight)
               else 
                  minimize_button:setSprite(sprite_normal)
               end 
            end
         end)
         minimize_button.label:free()
         minimize_button:setAnchor(1,0,1,0):setDimensions(-24,3,-17,10)
      end,
   },
   container = {
      ---@param container GNUI.container
      window_border_drag = function (container)
         local sprite_border_normal = gnui.newSprite():setTexture(texture):setUV(1,29,1,29)
         local sprite_border_active = gnui.newSprite():setTexture(texture):setUV(3,29,3,29)
         container.MOUSE_PRESSENCE_CHANGED:register(function (hovered,pressed)
            if pressed then
               container:setSprite(sprite_border_active)
            else
               if hovered then
                  container:setSprite(sprite_border_active)
               else 
                  container:setSprite(sprite_border_normal)
               end 
            end
         end)
         container:setSprite(sprite_border_normal)
      end
   }
}
