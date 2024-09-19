local text = 'git add .'

local swap = {
  {"q","p"},
  {"k","i"},
  {"b","t"},
  {"p","g"},
  {"f","h"},
  {"t","s"},
  {"l","u"},
  {"o","a"},
  {"r","d"},
  {"y","m"},
  {'Z','"'}
}

local condition = ""

for i = 1, #swap, 1 do
  text = text:gsub(swap[i][2],swap[i][1])
  condition = condition .. swap[i][1] .. " is " .. swap[i][2]..", "
end

text = "`"..text .. "`, but "..condition

print(text)
host:setClipboard(text)