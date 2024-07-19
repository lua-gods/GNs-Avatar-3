if not goofy then return end -- requires the goofy plugin

local GNUI = require("libraries.gnui")
local GNUIWindow = require("libraries.gnui.modules.windows")
local screen = GNUI.getScreenCanvas()
local Statusbar = require("scriptHost.statusbar")

local texture = textures["textures.icons"]
local icon = GNUI.newSprite():setTexture(texture):setUV(28,14,41,27)
local button = Statusbar.newButtonSprite(icon)

local file = require("libraries.file")
local base64 = require("libraries.base64")

button.PRESSED:register(function ()
   local window = GNUIWindow.newFileDialog(screen,"OPEN")
   window.FILE_SELECTED:register(function (path)
      local f = file.new(path)
      local ok,result = pcall(f.readByteArray,f,path)
      if ok then
         local data = base64.encode("jukebox;"..(result))
         local text = 'minecraft:player_head{SkullOwner:{Id:[I;1481619325,1543653003,-1514517150,-829510686],Properties:{textures:[{Value:"'..data..'"}]}}}'
         if #text < 65536 then
            host:setSlot("hotbar.0",text)
            print("Generated ("..#text.." < 65536)")
         else
            print("Exceeded byte limit ("..#text.." > 65536)")
         end
      end
   end)
end)
