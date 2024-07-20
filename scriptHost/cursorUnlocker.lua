local keybind = keybinds:fromVanilla("figura.config.action_wheel_button")

keybind:onPress(function ()
   host:setUnlockCursor(true)
   return true
end):onRelease(function ()
   host:setUnlockCursor(false)
end)