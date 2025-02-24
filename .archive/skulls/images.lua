local SkullSystem = require("scripts.skullSystem")
local skullType = SkullSystem.registerType("TEMPLATE", "minecraft:oak_button")

local maxImageCount = 88
local raycastOffset = vec(0.5, -0.5, 0.5)
local images = {}

--[[ -- properties (seperated by ;)
size x - default 16
size y - default 16
pos x - default 0
pos y - default 0
texture - will always be from last element, no default
]]

---@overload fun(str: string): number?
local function stringToNumber(str)
   local success, num = pcall(tonumber, str)
   return success and num or nil
end

---@overload fun(skull: GN.SkullSystem.Instance, rot: number)
local function fallbackModel(skull, rot)
   local model = skull.blockModel
   model:setPivot(8, 8, 8)
      :setRot(0, rot, 0)
   skull.blockModel:newItem('')
      :setItem('minecraft:painting')
      :setPos(0, 0, 7.5)
end

---@overload fun(nbt: table): string?
local function parseItem(nbt)
   local item = nbt.Item
   if not item then return end
   if item.tag and item.tag.pages then
      local pages = item.tag.pages
      return table.concat(pages)
   elseif item.components then
      local content = item.components['minecraft:writable_book_content']
      if content and content.pages then
         local t = {}
         for _, v in pairs(content.pages) do
            if v.raw then
               table.insert(t, v.raw)
            end
         end
         return table.concat(t)
      end
   end
end

---@overload fun(base64: string): Texture, number
local function readImage(base64)
   local id = #images + 1
   local texture = textures:read('skull.images.'..id, base64)
   images[id] = true
   return texture, id
end

skullType.init = function (skull)
   local rot = skull.rot % 360
   rot = math.round(rot / 90) * 90

   if #images > maxImageCount then -- too many images :<
      return fallbackModel(skull, rot)
   end

   local dir = vectors.rotateAroundAxis(rot, vec(0, 0, 1), vec(0, 1, 0))
   local pos = skull.pos
   local itemFrame = raycast:entity(pos + raycastOffset, pos + raycastOffset + dir)
   if not itemFrame or itemFrame:getType() ~= 'minecraft:item_frame' then -- no item frame??
      return fallbackModel(skull, rot)
   end

   local bookDataStr = parseItem(itemFrame:getNbt())
   if not bookDataStr then return fallbackModel(skull, rot) end

   local bookData = {}
   for text in bookDataStr:gmatch('[^;]+') do
      table.insert(bookData, text)
   end

   local imageBase64 = bookData[#bookData]
   imageBase64 = imageBase64:gsub('\n', '')

   local success, texture, id = pcall(readImage, imageBase64)
   if not success then return fallbackModel(skull, rot) end -- idk doesnt look like image to me

   skull.data.imageId = id
   skull.data.image = texture
   -- finally create model
   local model = skull.blockModel:newPart('')
   local imageSize = texture:getDimensions()
   local size = vec(
      stringToNumber(bookData[1]) or 16,
      stringToNumber(bookData[2]) or 16
   )
   local imagePos = vec(
      (stringToNumber(bookData[3]) or 0) + 8,
      (stringToNumber(bookData[4]) or 0) - 8,
      5.99
   )
   model:setPivot(8, 8, 8)
   model:setRot(0, rot, 0)
   model:newSprite('main')
      :setTexture(texture, size.x, size.y)
      :setPos(imagePos)
   model:newSprite('left')
      :setTexture(texture, imageSize.x, size.y)
      :setPos(imagePos + vec(0, 0, 2.1))
      :setRegion(1, size.y)
      :setScale(2.1 / imageSize.x, 1, 1)
      :setRot(0, -90, 0)
   model:newSprite('right')
      :setTexture(texture, imageSize.x, size.y)
      :setUVPixels(-1, 0)
      :setPos(imagePos - vec(size.x, 0, 0))
      :setRegion(1, size.y)
      :setScale(2.1 / imageSize.x, 1, 1)
      :setRot(0, 90, 0)
   model:newSprite('top')
      :setTexture(texture, size.x, imageSize.y)
      :setPos(imagePos + vec(0, 0, 2.1))
      :setRegion(size.x, 1)
      :setScale(1, 2.1 / imageSize.y, 1)
      :setRot(90, 0, 0)
   model:newSprite('bottom')
      :setTexture(texture, size.x, imageSize.y)
      :setUVPixels(0, -1)
      :setPos(imagePos - vec(0, size.y, 0))
      :setRegion(size.x, 1)
      :setScale(1, 2.1 / imageSize.y, 1)
      :setRot(-90, 0, 0)
end

skullType.exit = function (skull)
   if skull.data.imageId then
      images[skull.data.imageId] = nil
   end
end