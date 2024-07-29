local zlib = require("libraries.compression.zzlib")
local base64 = require("libraries.base64")
local nbt = require("libraries.nbt")

--local output = nbt.readFile("bigtest.nbt")
--[[
package = base64.encode(package)
local save = file:openWriteStream("output.nbt")

buff = data:createBuffer()
buff:writeBase64(package)
buff:setPosition(0)
buff:writeToStream(save)
save:flush()
save:close()
]]