local gnui = require("GNUI.main")
local texture = textures["GNUI.modules.theme.textures.element_default"]

---@type GNUI.theme
return {
  Container = {
    ---@param container GNUI.Container
    solid = function (container)
      local sprite = gnui.newSprite():setTexture(texture):setUV(1,32,3,34):setBorderThickness(2,2,2,2)
      container:setSprite(sprite)
    end,
    solid_white = function (container)
      local sprite = gnui.newSprite():setTexture(texture):setUV(1,36,3,38):setBorderThickness(2,2,2,2)
      container:setSprite(sprite)
    end,
    background = function (container)
      local sprite = gnui.newSprite():setTexture(texture):setUV(5,36,7,38):setBorderThickness(2,2,2,2)
      container:setSprite(sprite)
    end
  },
  ScrollbarButton = {
    ---@param container GNUI.ScrollbarButton
    default = function (container)
      local trackSprite = gnui.newSprite():setTexture(texture):setUV(35,18,39,22):setBorderThickness(2,2,2,2)
      container:setSprite(trackSprite)
      
      local scrollbarSprite = gnui.newSprite():setTexture(texture):setUV(23,17,27,22):setBorderThickness(2,2,2,3)
      container.Scrollbar:setSprite(scrollbarSprite)
    end
  }
}