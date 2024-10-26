for key, value in pairs(listFiles("pages.macros", true)) do
  require(value)
end