for key, value in pairs(listFiles("macros", true)) do
  require(value)
end