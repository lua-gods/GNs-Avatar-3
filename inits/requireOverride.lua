
local symlinkPath = "GN Avatar Path.txt"

local SYMLINK_AVATAR_PATH
if file:isFile(symlinkPath) then
   local buffah = data:createBuffer()
   buffah:readFromStream(file:openReadStream(symlinkPath))
   buffah:setPosition(0)
   local path = buffah:readString()
   buffah:close()
   if file:isPathAllowed(path) then
      if file:isDirectory(path) then
         SYMLINK_AVATAR_PATH = path
      end
   end
else
   printJson('{"text":"File \\"figura/data/'..symlinkPath..'\\" not found in the. Create this file with the path to this avatar from the figura/data folder; using a hard symlink, aka a Junction\n","color":"yellow"}')
end

if not SYMLINK_AVATAR_PATH then 
   printJson('{"text":"No symlink Avatar path. Host only scripts will not load.\n","color":"yellow"}')
end

local req = require

local preloaded = {}

---@param modname string
require = function (modname)
   
   local symlinkDir = SYMLINK_AVATAR_PATH
   local avatarDir = ""
   local fileName = ""
   local modified = false
   for word in modname:gsub("%.","/"):gmatch("[^/]+") do
      
      avatarDir = avatarDir .. "/" .. word
      local presumedPath = symlinkDir.."/"..word
      local swapped = false
      if file:isPathAllowed(presumedPath) then
         if not file:isDirectory(presumedPath) then -- not in the current scope
            if file:isDirectory(symlinkDir.."/."..word) then -- check if the path with a dot exists
               symlinkDir = symlinkDir.."/."..word
               modified = true
               swapped = true
            end
         end
      else
         break
      end
      if not swapped then
         symlinkDir = symlinkDir .. "/" .. word
      end
   end
   fileName = avatarDir:match("[^/]+$")
   avatarDir = avatarDir:sub(2,-1-#fileName)
   
   if modified then
      if preloaded[symlinkDir] then return table.unpack(preloaded[symlinkDir]) end -- already loaded, return the same values
      
      local buffer = data:createBuffer()
      local stream = file:openReadStream(symlinkDir..'.lua')
      buffer:readFromStream(stream)
      buffer:setPosition(0)
      local content = buffer:readByteArray()
      buffer:close()
      stream:close()
      local func = load(content)
      local status = {pcall(func, avatarDir, fileName)}
      if not status[1] then error(status[2], 2) end
      table.remove(status, 1) -- remove the error status
      preloaded[symlinkDir] = status
      return table.unpack(status)
   end
   return req(modname)
end