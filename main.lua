---@diagnostic disable: undefined-field

local function path2fancy(path)
  local paths = {}
  local json_paths = {}
  for word in string.gmatch(path..".","[^./]+") do
    paths[#paths+1] = word
  end

  for i, value in pairs(paths) do
    if i ~= #paths then
      table.insert(json_paths,1, {text=value,color="#797979"})
      table.insert(json_paths,1, {text="<",color="#464646"})
    else
      table.insert(json_paths,1, {text=value,color="#ff6464"})
    end
  end
  return json_paths
end

---@diagnostic disable-next-line: lowercase-global
function tracebackError(input)
  local path, line, comment = input:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1"):match("(.*):(%d+) (.*) stack traceback:")
  local compose = {}
  compose[#compose+1] = {text="\n"}
  compose[#compose+1] = {text="[Traceback]",color="#ff7b72"}
  local i = 0
  local f ={}
  for l in string.gmatch(input,"[^\n]+") do
    i = i + 1
    if i > 2 then
      table.insert(f,1,l)
    end
  end
  for k,l in pairs(f) do
      local trace_path,trace_comment = l:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1"):match("^(.*): (.*)$")
      local trace_line
      if trace_path:find(":") then -- if valid traceback format
        trace_path,trace_line = trace_path:match("^(.*):(.*)$")

        compose[#compose+1] = {text="\n"}
        compose[#compose+1] = {text=" "}
        compose[#compose+1] = {text = "↓ ",color="#797979"}
        compose[#compose+1] = {text = trace_line,color="#00ecfb"}
        compose[#compose+1] = {text = ":",color="#797979"}
        compose[#compose+1] = {text="",extra=path2fancy(trace_path)}
        compose[#compose+1] = {text = " : ",color="#797979"}
        compose[#compose+1] = {text=trace_comment,color="#896767"}
      end
  end

    

  local json_paths = path2fancy(path)
  compose[#compose+1] = {text="\n"}
  compose[#compose+1] = {text="[ERROR]",color="#ff7b72"}
  compose[#compose+1] = {text="\n"}
    
  compose[#compose+1] = {text = line,color="#00ecfb"}
  compose[#compose+1] = {text = ":",color="#797979"}
  compose[#compose+1] = {text=" ",extra=json_paths}
  
  compose[#compose+1] = {text = "\n "}
  compose[#compose+1] = {text = comment,color="#ff7b72"}
  compose[#compose+1] = {text = "\n\n"}

  printJson(toJson(compose))
end

local errors = 0
if events.ERROR then
  events.ERROR:register(function (error)
    errors = errors + 1
    tracebackError(error)
    if errors > 10 then goofy:stopAvatar() end
    return true
  end)
end

IS_HOST = host:isHost()
NOT_HOST = not IS_HOST

for key, value in pairs(listFiles("preload", true)) do require(value)end

for key, value in pairs(listFiles("scripts", false)) do require(value)end

if IS_HOST then
  for key, value in pairs(listFiles("scriptHost", true)) do require(value)end
end