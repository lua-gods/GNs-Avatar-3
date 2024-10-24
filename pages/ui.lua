local Dialog = require"libraries.dialog"
local page = Dialog.newPage({
  name = "UI Elements",
  color="#c5884b",
  positioning = "HOTBAR RIGHT",
})

local GNUI = require"GNUI.main"
local Button = require"GNUI.element.button"

local items = listFiles("pages.ui")

local macros = {}

events.WORLD_RENDER:register(function ()
  for key, macro in pairs(macros) do
    if macro.FRAME then macro.FRAME() end
  end
end)

events.WORLD_TICK:register(function ()
  for key, macro in pairs(macros) do
    if macro.TICK then macro.TICK() end
  end
end)

for key, item in pairs(items) do
  if item ~= "pages.ui" then
    local name = item:match("[^.]+$")
    
    page:newRow({
      label=name})
      page:newCustomUI({
        init = function(parent)
          local toggle = Button.new(parent)
          :setAnchor(0,0,1,1):setDimensions(0,0,-14,0)
          config:setName("GN.pages.ui")
          
          local macro = require(item)
          macros[item] = macro
          

          local function refresh()
            local enabled = config:load(item) and true or false
          
            if enabled then toggle:setText({text="True",color="dark_green"})
            else toggle:setText({text="False",color="dark_red"})
            end
            macro.wasEnabled = true
            macro.enabled = enabled
            if enabled and macro.ENABLE then macro.ENABLE() end
            if not enabled and macro.wasEnabled and macro.DISABLE then macro.DISABLE() end
          end
          
          refresh()
          
          toggle.PRESSED:register(function()
            config:save(item,not config:load(item))
            refresh()
          end)
          
          local settings = Button.new(parent)
          :setAnchor(1,0,1,1):setDimensions(-15,0,0,0):setText("+")
        end
      })
  end
end

page:newSeparator()
page:newReturnButton()


return page