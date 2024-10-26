local Dialog = require"libraries.dialog"
local page = Dialog.newPage({
  name = "UI Elements",
  color="#c5884b",
  positioning = "HOTBAR RIGHT",
})

local GNUI = require"GNUI.main"
local screen = GNUI.getScreenCanvas()
local Button = require"GNUI.element.button"

local Macros = {} ---@type table<string,Macro>
local items = listFiles("pages.ui")
for key, item in pairs(items) do
  if item ~= "pages.ui" then
    local name = item:match("[^.]+$")
    local macro = require(item) ---@type Macro
    Macros[name] = macro
  end
end

page.PREPROCESS:register(function()
  
end)

for name, item in pairs(Macros) do
  if item ~= "pages.ui" then
    page:newRow({
      label=name})
      page:newCustomUI({
        init = function(parent)
          local toggle = Button.new(parent)
          :setAnchor(0,0,1,1):setDimensions(0,0,-14,0)
          config:setName("GN.pages.ui")
          

          local function refresh()
            local enabled = config:load(name) and true or false
          
            if enabled then toggle:setText({text="True",color="dark_green"})
            else toggle:setText({text="False",color="dark_red"})
            end
            item:setActive(enabled)
          end
          
          refresh()
          
          toggle.PRESSED:register(function()
            config:save(name,not config:load(name))
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