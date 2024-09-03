MS = {}

local durations = {}
local durationsName = {}
local duration = 0
local dname = ""
local dbig = 0

---Clears the duration list.
function MS.clr()
  dbig = 0
  durations = {}
end

---Starts a duration test.
function MS.a(ctx)
  dname = ctx
  duration = client:getSystemTime()
end

---Ends a duration test.
function MS.b()
  local t = client:getSystemTime() - duration
  durations[#durations+1] = t
  durationsName[#durationsName+1] = dname
  dbig = math.max(dbig,t)
end

local disp

function MS.disp()
  local txt = '{"text":"Miliseconds Debug  ","color":"red"},'
  local info = ""
  if not disp then
    disp = models:newPart("GNMSdebug","HUD"):pos(0,-20,-100):newText("debug")
  end
  local bname = 0
  local beeg = 0
  for i = 1, #durations, 1 do
    bname = math.max(bname,client.getTextWidth(durationsName[i] or "100") )
    beeg = beeg + math.ceil(durations[i])
  end
  for i = 1, #durations, 1 do
    local e = tostring(durationsName[i] or i)
    local f = ""
    f = ("."):rep((bname-client.getTextWidth(e)) / 2)
    local t = durations[i]
    local msf = ""
    msf = ("."):rep((50-client.getTextWidth(t)) / 2)
    
    local accent = vectors.rgbToHex(vectors.hsvToRGB(i / #durations * 3, 0.9, 1))
    info = info .. ('{"text":"%s","color":"#'..accent..'"},{"text":"%s","color":"black"},{"text":": ","color":"gray"},{"text":"%s ms","color":"#'..vectors.rgbToHex(vectors.hsvToRGB((1-t/dbig) * 0.3,1,1))..'"},{"text":"%s","color":"black"},{"text":"'..('|'):rep(math.ceil(t / dbig * 100))..'","color":"#'..accent..'"},{"text":" \n","color":"gray"},'):format(e,f,t,msf)
    txt = txt .. '{"text":"'..('|'):rep(math.ceil(t / beeg * 100))..' ","color":"#'..accent..'"},'
  end
  txt = txt .. '{"text":"\n"},'
  disp:setText("["..txt..info:sub(1,-2).."]"):setBackground(true):setBackgroundColor(0,0,0,1)
end