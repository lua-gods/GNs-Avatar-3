models.playerHead:setParentType("SKULL")
local modelPlushie = models.playerHead.plushie
local modelHead = models.playerHead.head:scale(1.15,1.15,1.15)
local modelItem = models.playerHead.item:scale(1.2,1.2,1.2)

local avatarVars = {}
local function colorGrade(clr,hue,saturation,value)
   local hsv = vectors.rgbToHSV(clr)
   return vectors.hsvToRGB(math.lerp(hsv.x,0.5,clr.g*hue),math.clamp(saturation + hsv.y,0,1),math.clamp(value + hsv.z,0,1))
end

events.SKULL_RENDER:register(function (delta, block, item, entity, ctx)
   if ctx == "HEAD" then
      local vars = avatarVars[entity:getUUID()] or {}
      local color = vars.color or "#5ac54f"
      local height = vars.hat_height and tonumber(vars.hat_height) or 7
      if type(color) == "string" then
         color = vectors.hexToRGB(color)
      end
      modelHead.cylinder:setScale(1,height or 10,1)
      modelHead.ribbon.shade4:setColor(color)
      modelHead.ribbon.shade3:setColor(colorGrade(color,0.25,0.05,-0.1))
      modelHead.ribbon.shade2:setColor(colorGrade(color,0.5,0.25,-0.25))
      modelHead.ribbon.shade1:setColor(colorGrade(color,0.75,0.5,-0.4))
      
      modelPlushie:setVisible(false)
      modelHead:setVisible(true)
      modelItem:setVisible(false)
   elseif ctx == "BLOCK" then
      modelPlushie:setVisible(true)
      modelHead:setVisible(false)
      modelItem:setVisible(false)
   else
      modelPlushie:setVisible(false)
      modelHead:setVisible(false)
      modelItem:setVisible(true)
   end
end)

events.WORLD_RENDER:register(function (delta)
   avatarVars = world.avatarVars()
end)