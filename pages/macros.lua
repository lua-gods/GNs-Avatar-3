local Dialog = require"libraries.dialog"
local page = Dialog.newPage({
  name = "Macros",
  color="#e45959",
  positioning = "HOTBAR RIGHT",
})

local GNUI = require"GNUI.main"
local screen = GNUI.getScreenCanvas()
local Button = require"GNUI.element.button"

local Macros = {} ---@type table<string,table<string,Macro>>
local items = listFiles("pages.macros",true)
for key, item in pairs(items) do
  if item ~= "pages.macros" then
    local words = {}
    for word in item:gmatch("[^%.]+") do
      words[#words+1] = word
    end
    local name = words[#words]
    local category = words[#words-1] or "Generic"
    local macro = require(item) ---@type Macro
    
    if not Macros[category] then
      Macros[category] = {}
    end
    Macros[category][name] = macro
  end
end

page.PREPROCESS:register(function()
  
end)

for categoryName, categoryContent in pairs(Macros) do
  for name, item in pairs(categoryContent) do
    if item ~= "pages.ui" then
      page:newRow({
        label = categoryName,
      })
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
        page:newSeparator()
    end
  end
end

page:newReturnButton()


return page