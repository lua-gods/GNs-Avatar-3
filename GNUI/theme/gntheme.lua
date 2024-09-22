--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / Theme File
/ /_/ / /|  / Contains how to theme specific classes
\____/_/ |_/ Source: link]]

--[[ Layout --------
├Class
│├Default
│└AnotherVariant
└Class
 ├Default
 ├Variant
 └MoreVariant
-------------------]]
---GNUI.Button        ->    Button
---GNUI.Button.Slider ->    Slider

local GNUI = require "GNUI.main"
local atlas = textures["GNUI.theme.gnuiTheme"]

---@type GNUI.Theme
return {
  Box = {
    Default = function (box)end,
    Solid = function (box)
      local spritePressed = GNUI.newNineslice(atlas,2,2,2,2 ,1,7,3,9)
      box:setNineslice(spritePressed)
    end
  },
  Button = {
    ---@param box GNUI.Button
    Default = function (box)
      local spriteNormal = GNUI.newNineslice(atlas,2,2,2,4 ,7,1,11,7, 2)
      local spritePressed = GNUI.newNineslice(atlas,2,2,2,2 ,13,3,17,7)
      
      box:setDefaultTextColor("black"):setTextAlign(0.5,0.5)
      
      local wasPressed = false
      box.BUTTON_CHANGED:register(function (pressed,hovering)
        if pressed ~= wasPressed then
          wasPressed = pressed
          if pressed then
            
            box:setNineslice(spritePressed)
            :setTextOffset(0,2)
            GNUI.playSound("minecraft:ui.button.click",1)
          else
            GNUI.playSound("minecraft:block.wooden_button.click_on",0.7)
            box:setNineslice(spriteNormal)
            :setTextOffset(0,0)
          end
        end
      end)
      
      box:setNineslice(spriteNormal)
    end
  },
}