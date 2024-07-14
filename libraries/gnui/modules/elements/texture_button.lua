---@diagnostic disable: assign-type-mismatch
-- Serves as a way to create buttons with custom textures without having to make a theme for it.

local gnui = require("libraries.gnui")
local themes = require("libraries.gnui.modules.themes")
local eventLib = require("libraries.eventLib")
local button = require("libraries.gnui.modules.elements.button")

---@class GNUI.TextureButton : GNUI.Button
---@field sprite_pressed Ninepatch
---@field sprite_hover Ninepatch
---@field sprite_normal Ninepatch
local TextButton = {}
TextButton.__index = function (t,i)
   return rawget(t,i) or TextButton[i] or button[i] or gnui.Container[i] or gnui.Element[i]
end
TextButton.__type = "GNUI.element.container.button.text_button"

---Creates a new button.
---@param variant string?
---@param theme string?
---@return GNUI.TextureButton
function TextButton.new(variant,theme)
   variant = variant or "default"
   theme = theme or "default"
   ---@type GNUI.TextureButton
   local new = button.new()
   setmetatable(new,TextButton)
   return new
end


---Sets the texture that displays when the button is pressed
---@param texture Texture?
---@param border_left number?
---@param border_top number?
---@param border_right number?
---@param border_bottom number?
function TextButton:setTextureNormal(texture,border_left,border_top,border_right,border_bottom)
   if texture == nil then self.sprite_normal:free() self.sprite_normal = nil
   else self.sprite_normal = gnui.newSprite():setTexture(texture):setBorderThickness(border_left,border_top,border_right,border_bottom)
   end
end

---Sets the texture that displays when the button is hovered
---@param texture Texture?
---@param border_left number?
---@param border_top number?
---@param border_right number?
---@param border_bottom number?
function TextButton:setTextureHover(texture,border_left,border_top,border_right,border_bottom)
   if texture == nil then self.sprite_hover:free() self.sprite_hover = nil
   else self.sprite_hover = gnui.newSprite():setTexture(texture):setBorderThickness(border_left,border_top,border_right,border_bottom)
   end
end

---Sets the texture that displays when the button is pressed
---@param texture Texture?
---@param border_left number?
---@param border_top number?
---@param border_right number?
---@param border_bottom number?
function TextButton:setTexturePressed(texture,border_left,border_top,border_right,border_bottom)
   if texture == nil then self.sprite_pressed:free() self.sprite_pressed = nil
   else self.sprite_pressed = gnui.newSprite():setTexture(texture):setBorderThickness(border_left,border_top,border_right,border_bottom)
   end
end

return TextButton