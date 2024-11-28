--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / Gradient object
/ /_/ / /|  / easily create gradients.
\____/_/ |_/ Source: https://github.com/lua-gods/GNs-Avatar-3/blob/main/lib/gradient.lua]]
---@diagnostic disable: return-type-mismatch

---@class Gradient
---@field colors Vector3[]
---@field positions number[]
---@field range number
local Gradient = {}
Gradient.__index = Gradient
Gradient.__type = "Gradient"

---@param config table<number, Vector3|string>?
---@return Gradient
function Gradient.new(config)
   local self = {
      colors = {},
      positions = {},
      range = 1,
   }
   setmetatable(self,Gradient)
   if config then
      for pos,color in pairs(config) do
         self:addPoint(pos,color)
      end
   end
   return self
end

---Adds a point to the gradient.
---@param pos number
---@param color Vector3|string?
function Gradient:addPoint(pos,color)
   if not color then
      color = self:sample(pos)
   else
      local t = type(color)
      if t == "string" then color = vectors.hexToRGB(color) end
   end
   local found = false
   local poses = self.positions
   for i = 1, #self.colors do
      if poses[i] > pos then
         table.insert(self.colors,i,color)
         table.insert(self.positions,i,pos)
         found = true
         break
      end
   end
   if not found then
      self.colors[#self.colors+1] = color
      self.positions[#self.positions+1] = pos
   end
   self.range = self.positions[#self.positions]
   return self
end

---Removes a point in the gradient.
---@param id number
---@return Gradient
function Gradient:removePoint(id)
   table.remove(self.colors,id)
   table.remove(self.positions,id)
   self.range = self.positions[#self.positions]
   return self
end

---Returns the id of the point in the gradient.
---@param pos any
---@return integer
function Gradient:getPointID(pos)
   local positions = self.positions
   local colors = self.colors
   for i = 1, #self.colors, 1 do
      if positions[i] < pos then
         return i
      end
   end
   return -1
end

---Moves a point in the gradient.
---@param id number
---@param to number
---@return Gradient
function Gradient:movePoint(id,to)
   local color = self.colors[id]
   self:removePoint(id)
   self:addPoint(to,color)
   return self
end

---Returns a color from the gradient in the given position.
---@param pos number
---@return Vector3
function Gradient:sample(pos)
   local positions = self.positions
   local colors = self.colors
   for i = 1, #self.colors, 1 do
      if positions[i] > pos then
         local j = (i-2)%#colors+1
         local colorA = colors[j]
         local colorB = colors[i]
         local posA = positions[j]
         local posB = positions[i]
         local t = math.map(pos,posA,posB,0,1)
         return math.lerp(colorA,colorB,t)
      end
   end
   return vec(0,0,0)
end

---Returns a color from the gradient in the given position. from a range of 0 to 1.
---@param pos number
---@return Vector3
function Gradient:sampleRange(pos)
   return self:sample(pos*self.range)
end

return Gradient