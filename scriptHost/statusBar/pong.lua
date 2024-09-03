local GNUI = require("GNUI.main")
-- GNUI Modules
local Elements = require("GNUI.modules.elements")
local Window = require("GNUI.modules.windows")
local Themes = require("GNUI.modules.themes")
-- Screen Stuffs
local screen = GNUI.getScreenCanvas()
local Statusbar = require("scriptHost.statusbar")
local icon = GNUI.newSprite():setTexture(textures["textures.icons"]):setUV(70,42,83,55)

local button = Statusbar.newButtonSprite("Pong",icon)

local WINDOW_SIZE = vec(480,360) * 0.5
local PAD_SIZE = 64
local PAD_THICKNESS = 8
local PAD_MARGIN = 16
local BALL_SIZE = 8
local P2_SPEED = 2
local BALL_SPEED = 300

local BHALF = BALL_SIZE * 0.5
local PHALF = PAD_SIZE * 0.5
local function newGame()
  local w = Window.newWindow(true,true)
  local ss = client:getScaledWindowSize() * 0.5
  w:setTitle("Pong")
  w:setPos(ss - WINDOW_SIZE * 0.5)
  w:setSize(WINDOW_SIZE)
  screen:addChild(w)
  w:forceUpdate()
  local size = w.ClientArea.Size
  
  local sprite = GNUI.newSprite(textures["1x1white"])
  
  local player1 = GNUI.newContainer():setSprite(sprite:copy())
  local player2 = GNUI.newContainer():setSprite(sprite:copy())
  local ball = GNUI.newContainer():setSprite(sprite:copy()):setSize(BALL_SIZE,BALL_SIZE)
  
  local p1Score = 0
  local p2Score = 0
  local p1Pos = 0
  local p2Pos = 0
  local bPos = size:copy():scale(0.5)
  local bVel
  local playing = false
  
  local startLabel = GNUI.newLabel()
  startLabel:setText("Click to Start!"):setAnchor(0,0,1,1):setAlign(0.5,0.5):setTextEffect("OUTLINE")
  local p1ScoreLabel = GNUI.newLabel()
  p1ScoreLabel:setText(tostring(p1Score)):setAnchor(0,0,1,1):setAlign(0.25,0.1):setTextEffect("OUTLINE"):setBlockMouse(false):setFontScale(2)
  local p2ScoreLabel = GNUI.newLabel()
  p2ScoreLabel:setText(tostring(p2Score)):setAnchor(0,0,1,1):setAlign(0.75,0.1):setTextEffect("OUTLINE"):setBlockMouse(false):setFontScale(2)
  
  local function start()
   playing = true
   bPos = size:copy():scale(0.5)
   bVel = vec(math.random(-1,0)*2+1,math.random()-0.5):normalized():scale(0.4)
  end
  
  w:addElement(player1)
  w:addElement(player2)
  w:addElement(ball)
  w:addElement(startLabel)
  w:addElement(p1ScoreLabel)
  w:addElement(p2ScoreLabel)
  
  local lastSystemTime = client:getSystemTime()
  events.WORLD_RENDER:register(function ()
   local systemTime = client:getSystemTime()
   local delta = (systemTime - lastSystemTime) / 1000
   lastSystemTime = systemTime
   
   player1:setDimensions(PAD_MARGIN-PAD_THICKNESS,p1Pos,PAD_MARGIN,PAD_SIZE+p1Pos)
   player2:setDimensions(size.x-PAD_MARGIN,p2Pos,size.x-PAD_MARGIN+PAD_THICKNESS,PAD_SIZE+p2Pos)
   ball:setPos(bPos-BHALF)
   if playing then
    bPos = bPos + bVel * delta * BALL_SPEED
    if bPos.y < BHALF then bVel.y = math.abs(bVel.y) end
    if bPos.y > size.y-BHALF then bVel.y = -math.abs(bVel.y) end
    if bPos.x < PAD_MARGIN+BHALF and bPos.x > PAD_MARGIN+BHALF-PAD_THICKNESS and bPos.y > p1Pos and bPos.y < p1Pos + PAD_SIZE then
      bVel = vec(PHALF*0.5,bPos.y-p1Pos-BHALF-PHALF):normalized() * bVel:length() * 1.02
    end
    if bPos.x > size.x-PAD_MARGIN-BHALF and bPos.x < size.x-PAD_MARGIN-BALL_SIZE+PAD_THICKNESS and bPos.y > p2Pos and bPos.y < p2Pos + PAD_SIZE then
      bVel = vec(-PHALF*0.5,bPos.y-p2Pos-BHALF-PHALF):normalized() * bVel:length() * 1.02
    end
    if bPos.x < 0 then
      p2Score = p2Score + 1
      p2ScoreLabel:setText(tostring(p2Score))
      w:setTitle(("Pong %s | %s"):format(p1Score,p2Score))
      start()
    end
    if bPos.x > size.x+BALL_SIZE then
      p1Score = p1Score + 1
      p1ScoreLabel:setText(tostring(p1Score))
      w:setTitle(("Pong %s | %s"):format(p1Score,p2Score))
      start()
    end
    p2Pos = math.clamp((math.clamp(bPos.y - PHALF - p2Pos,-P2_SPEED,P2_SPEED) + p2Pos),0,size.y-PAD_SIZE)
   end
  end,"pong"..w.id)
  w.ClientArea.MOUSE_MOVED:register(function (event)
   p1Pos = math.clamp(w.ClientArea:toLocal(event.pos).y-PHALF,0,size.y-PAD_SIZE)
  end)
  startLabel.MOUSE_PRESSENCE_CHANGED:register(function (hover,pressed)
   if pressed then
    startLabel:setVisible(false)
    start()
   end
  end)
  
  w.CLOSE_REQUESTED:register(function ()
   w:close()
   events.WORLD_RENDER:remove("pong"..w.id)
  end)
end

button.PRESSED:register(function ()
  newGame()
end)
