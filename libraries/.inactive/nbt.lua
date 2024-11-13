--[[______  __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / A library that reads NBT.
/ /_/ / /|  / 
\____/_/ |_/ Source: https://github.com/lua-gods/GNs-Avatar-3/blob/main/libraries/nbt.lua]]
--BIG Thankyou to the NBT wiki: https://wiki.vg/NBT

-->==========[ Dependencies ]==========<--
local zlib = require("libraries.compression.zzlib") -- Optional
local base64 = require("libraries.base64") -- Required

-->==========[ Types ]==========<--
---@alias NBT.Types integer
---|  0 # TAG_End
---|  1 # TAG_Byte
---|  2 # TAG_Short
---|  3 # TAG_Int
---|  4 # TAG_Long 
---|  5 # TAG_Float
---|  6 # TAG_Double
---|  7 # TAG_Byte_Array
---|  8 # TAG_String
---|  9 # TAG_List
---| 10 # TAG_Compound
---| 11 # TAG_Int_Array
---| 12 # TAG_Long_Array

---@class NBT.Compound
---@field name string
---@field tags NBT.Element[]

---@class NBT.Element
---@field type NBT.Types
---@field name string
---@field value number

local NBT = {}

---Reads a TAG_String
---@param b Buffer
---@return string
local function readString(b)
  return b:readString(b:readShort())
end

---@param b Buffer
---@return NBT.Element?
local function readElement(b)
  local t = b:read() -- read type
  local name = readString(b)
  local value = NBT.readType(b,t)
  if t <= 0 then return end
  return {type = t,name = name,value = value}
end


---@param b Buffer
---@return NBT.Compound
local function readCompound(b)
  local out = {}
  out.name = b:readString(b:readShort())
  out.tags = {}
  for i = 1, 10, 1 do
    local e = readElement(b)
    if not e then break end
    out.tags[i] = e
  end
  return out
end

---Reads the TAG_Any into its converted form.
---@param b Buffer
---@param type NBT.Types
function NBT.readType(b,type)
  if type == 1 then -- TAG_Byte
    return b:read()
  elseif type == 2 then -- TAG_Short
    return b:readShort()
  elseif type == 3 then -- TAG_Int
    return b:readInt()
  elseif type == 4 then -- TAG_Long
    return b:readLong()
  elseif type == 5 then -- TAG_Float
    return b:readFloat()
  elseif type == 6 then -- TAG_Double
    return b:readDouble()
  elseif type == 7 then -- TAG_Byte_Array
    local length = b:readInt()
    local out = {}
    for i = 1, length, 1 do
      out[i] = b:read()
    end
    return out
  elseif type == 8 then -- TAG_String
    return readString(b)
  elseif type == 9 then -- TAG_List
    local listType = b:read()
    local length = b:readInt()
    local out = {}
    for i = 1, length, 1 do
      out[i] = NBT.readType(b,listType)
    end
    return out
  elseif type == 10 then -- TAG_Compound
    b:read()
    return readCompound(b)
  elseif type == 11 then -- TAG_Int_Array
    local length = b:readInt()
    local out = {}
    for i = 1, length, 1 do
      out[i] = b:readInt()
    end
    return out
  elseif type == 12 then -- TAG_Long_Array
    local length = b:readInt()
    local out = {}
    for i = 1, length, 1 do
      out[i] = b:readLong()
    end
    return out
  end
end


---Reads an uncompressed NBT string.  
---If the string is compressed, it will be decompressed.
---@param path string
---@return NBT.Compound
function NBT.readFile(path)
  local readBuffer = data:createBuffer()
  readBuffer:readFromStream(file:openReadStream(path))
  readBuffer:setPosition(0)
  local package = readBuffer:readBase64()
  
  package = base64.decode(package)
  --package = zlib.gunzip(package) -- uncomment if compressed
  
  local buff = data:createBuffer(package:len())
  buff:writeByteArray(package) -- setup reading
  buff:setPosition(0)
  
  if buff:read() ~= 10 then -- is probably compressed, decomressing with gzip
    package = zlib.gunzip(package)
    buff:close()
    buff = data:createBuffer(package:len())
    buff:writeByteArray(package)
  end
  
  buff:setPosition(1)
  return readCompound(buff)
end

return NBT