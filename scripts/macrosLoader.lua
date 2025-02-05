for key, value in pairs(listFiles("macros",true)) do
	require(value)
end

require("scriptHost.ui.macros")