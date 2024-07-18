local gnui = require("libraries.gnui")
local texture = textures["libraries.gnui.modules.theme.textures.element_default"]
local tween = require("libraries.tween")

---@type GNUI.theme
return {
   TextButton = {
      ---@param container GNUI.TextButton
      default = function (container)
         local label = container.label
         
         local sprite_normal = gnui.newSprite():setTexture(texture):setUV(9,2,13,8):setBorderThickness(2,2,2,4)
         local sprite_hovered = gnui.newSprite():setTexture(texture):setUV(15,2,19,8):setBorderThickness(2,2,2,4)
         local sprite_pressed = gnui.newSprite():setTexture(texture):setUV(21,2,25,8):setBorderThickness(2,4,2,2)
         
         container:setSprite(sprite_normal)
         container.MOUSE_PRESSENCE_CHANGED:register(function (hovered,pressed)
            if pressed then
               container:setSprite(sprite_pressed)
               label:setDimensions(2,6,-2,-2)
            else
               if hovered then container:setSprite(sprite_hovered)
               else container:setSprite(sprite_normal)
               end label:setDimensions(2,2,-2,-2)
            end
         end)
         
         label:setAnchor(0,0,1,1)
         label:setDimensions(2,2,-2,-2)
         label:setText("Text")
         label:setDefaultColor('black')
         label:setCanCaptureCursor(false)
         label:setAlign(0.5,0.5)
         container.SystemMinimumSize.y = 16
      end,
   },
}