local GNUI = require("GNUI.main")
local GNUIWindow = require("GNUI.modules.windows")
local screen = GNUI.getScreenCanvas()
local Statusbar = require("scriptHost.statusbar")

local texture = textures["textures.icons"]
local icon = GNUI.newSprite():setTexture(texture):setUV(28,14,41,27)
local button = Statusbar.newButtonSprite("4p5 Jukebox Generator",icon)

local file = require("libraries.file")
local base64 = require("libraries.base64")

button.PRESSED:register(function ()
   local window = GNUIWindow.newFileDialog(screen,"OPEN")
   window.FILE_SELECTED:register(function (path)
      local f = file.new(path)
      local ok,result = pcall(f.readByteArray,f,path)
      if ok then
         local data = base64.encode("jukebox;"..(result))
         compare(#result,#data)
         local item = 'minecraft:player_head{SkullOwner:{Id:[I;1481619325,1543653003,-1514517150,-829510686],Properties:{textures:[{Value:"'..data..'"}]}}}'
         if #item < 65536 then
            give(item)
            print("Generated ("..#item.." < 65536)")
         else
            print("Exceeded byte limit ("..#item.." > 65536)")
         end
      end
   end)
end)
