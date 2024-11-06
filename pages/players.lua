local Dialog = require"libraries.dialog"
local page = Dialog.newPage({
  name = "Player List",
  color="#c5b565",
  positioning = "HOTBAR RIGHT",
})

local GNUI = require"GNUI.main"
local Button = require"GNUI.element.button"

local playerPages = {}

page.PREPROCESS:register(function()
  page.rows = {}
  local players = client:getTabList().players
  for i = 1, #players, 1 do
    local name = players[i]
    local playerPage
    if not playerPages[name] then
      playerPage = Dialog.newPage({
        name = name,
        color="#c5b565",
        positioning = "HOTBAR RIGHT",
      })
      
      
      if player:getGamemode() == "CREATIVE" then -- require creative
        playerPage:newButton({
          label = "Creative",
          text="Get Head",
          onClick = function()
            host:setSlot(player:getNbt().SelectedItemSlot,'minecraft:player_head{SkullOwner:"'..name..'"}')
          end
        })
      end
      
      if player:getPermissionLevel() > 1 then -- requre commands
        playerPage:newSeparator()
      
        playerPage:newButton({
          label = "Operator",
          text="Teleport To",
          onClick = function()
            host:sendChatCommand("/tp @s "..name)
          end
        })
        
        playerPage:newButton({
          label = " ",
          text="Teleport Here",
          onClick = function()
            host:sendChatCommand("/tp "..name.." @s")
          end
        })
      end
      
      
      playerPage:newSeparator()
      
      playerPage:newReturnButton()
      playerPages[name] = playerPage
    else
      playerPage = playerPages[name]
    end
    page:newPageButton({
      text = name,
      icon = 'minecraft:player_head{SkullOwner:"'..name..'"}',
      page = playerPage
    })
  end
  
  page:newSeparator()
  page:newReturnButton()
end)



return page