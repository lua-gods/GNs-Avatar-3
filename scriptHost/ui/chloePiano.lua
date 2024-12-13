
local Tween = require("lib.tween")

local GNUI = require("lib.GNUI.main")
local Pages = require"lib.pages"
local Button = require"lib.GNUI.element.button"


local NOTES = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" }

local page = Pages.newPage("chloePiano",{bgOpacity=0})
---@param screen GNUI.Box
page.INIT:register(function (screen)
   local piano = world.avatarVars()["b0e11a12-eada-4f28-bb70-eb8903219fe5"]
   local id = vec(-99779,67,-98370):toString()
   -- close button
   Button.new(screen)
   :setPos(32,32)
   :setSize(16,16)
   :setText("x")
   
   local keyboard = GNUI.newBox(screen)
   :setAnchor(0,1,1,1)
   :setDimensions(5,-40,-5,-5)
   
   local keyboardMinors = GNUI.newBox(screen)
   :setAnchor(0,0.75,1,1)
   :setDimensions(5,0,-5,-40)
   
   local p = 0
   local note = -1
   for i = 1, 7*6, 1 do
      note = note + 1
      local octave = math.floor(note/12)+1
      local majorKey = Button.new(keyboard)
      :setPos(p*20,-40)
      :setSize(20,40)
      :setAnchor(0,0,0,1)
      local n = note
      majorKey.BUTTON_DOWN:register(function ()
         piano.playNote(id, NOTES[n%#NOTES+1]..octave,true)
      end)
      if octave%2 == 0 then
         majorKey:setColor(0.75,0.75,0.75)
      end
      p = p + 1
      local octaveNote = (i-1) % 7+1
      if octaveNote ~= 3 and octaveNote ~= 7 then
         note = note + 1
         local minorKey = Button.new(keyboardMinors)
         :setPos((p-0.5)*20+2.5,0)
         :setSize(15,0)
         :setAnchor(0,0,0,1)
         :setColor(0.2,0.2,0.2)
         minorKey.BUTTON_DOWN:register(function ()
            piano.playNote(id, NOTES[(n+1)%#NOTES+1]..octave,true)
         end)
      end
   end
   local shift = 0
   events.MOUSE_SCROLL:register(function (dir)
      shift = shift + dir * 20
      Tween.tweenFunction(keyboard.offsetChildren.x,shift,0.1,"linear",function(x)
         local pos = vec(x,0)
         keyboard:setChildrenOffset(pos)
         keyboardMinors:setChildrenOffset(pos)
      end,nil,"pianoscroll")
      return true
   end,"pianoscroll")
end)

page.EXIT:register(function ()
   events.MOUSE_SCROLL:remove("pianoscroll")
end)