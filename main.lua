for key, value in pairs(listFiles("autoscripts", true)) do
   require(value)
end

if host:isHost() then
   for key, value in pairs(listFiles("hostAutoscripts", true)) do
      require(value)
   end
end