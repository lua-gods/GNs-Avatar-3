--[[______   __                _                 __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]
-- Source: https://github.com/lua-gods/GNs-Avatar-3/
-- Info: Github: @GNamimates, Discord: @gn8., Youtube: @GNamimates
-- My Personal Avatar.

for key, value in pairs(listFiles("inits")) do require(value) end
if host:isHost() then for key, value in pairs(listFiles("debug", true)) do require(value) end end
for key, value in pairs(listFiles("scripts", true)) do require(value) end
if host:isHost() then for key, value in pairs(listFiles("scriptHost", true)) do require(value) end end