for key, value in pairs(listFiles("scripts", true)) do
   require(value)
end

if host:isHost() then
   for key, value in pairs(listFiles("scriptHost", true)) do
      require(value)
   end
end