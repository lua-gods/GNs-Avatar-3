_G.utils = {}
for key, value in pairs(listFiles("lib.utils", true)) do
   require(value)
end