function compare(...)
  local t = {...}
  local biggest = 0
  for i = 1, #t, 1 do
    biggest = math.max(biggest,t[i])
  end
  for i = 1, #t, 1 do
    print(t[1],(math.floor(t[i]/biggest*1000)/10).."%")
  end
end