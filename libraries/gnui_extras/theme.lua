local gnui = require("libraries.gnui")
local texture = textures["libraries.gnui_extras.textures.ui.gnui_theme"]
local tween = require("libraries.tween")

---@alias GNUI.theme table<string,{variants:{default:fun(container:GNUI.button,label:GNUI.label):GNUI.container}}>

---@type GNUI.theme
local theme = {
 button = {
  variants = {
   default = function (container,label)
      container:addChild(label)
      
      local sprite_normal = gnui.newSprite():setTexture(texture):setUV(8,57,12,63):setBorderThickness(2,2,2,4)
      local sprite_hovered = gnui.newSprite():setTexture(texture):setUV(14,57,18,63):setBorderThickness(2,2,2,4)
      local sprite_pressed = gnui.newSprite():setTexture(texture):setUV(20,57,24,63):setBorderThickness(2,4,2,2)
      
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
      label:setDefaultColor("black")
      label:setCanCaptureCursor(false)
      label:setAlign(0.5,0.5)
      container.SystemMinimumSize.y = 24
      return container
   end,
  },
 },
}
return theme