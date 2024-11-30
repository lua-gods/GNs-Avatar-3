--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / A service library for handling which page should be displayed at the screen.
/ /_/ / /|  / 
\____/_/ |_/ Source: https://github.com/lua-gods/GNs-Avatar-3/blob/main/lib/pages.lua]]
local CONFIG_KEY = avatar:getName()..".lastPage"

local eventLib = require"lib.eventLib"
local GNUI = require"lib.GNUI.main"
local screen = GNUI.getScreenCanvas()

local background = textures["1x1white"] or textures:newTexture("1x1white",1,1):setPixel(0,0,vec(1,1,1))


local pages = {} ---@type table<string, GNUI.page>
local currentPage ---@type GNUI.page?
local history = {}

---@class GNUI.PageRizzler
local pageRizzler = {
	PAGE_CHANGED = eventLib.new(),
	pages = pages,
}



---@param name string
---@param config {bgOpacity:number?,unlockCursor:boolean?}
function pageRizzler.newPage(name,config)
	config = config or {}
	print(config,not (config and config.unlockCursor ~= nil and ( not config.unlockCursor)))
	local page = {
		bgOpacity = config.bgOpacity or 0.5,
		unlockCursor = not (config and config.unlockCursor ~= nil and not config.unlockCursor),
		INIT = eventLib.new(),
		EXIT = eventLib.new(),
	}
	if pages[name] then error("page "..name.." already exists",2) end
	pages[name] = page
	return page
end


local defaultPage = pageRizzler.newPage("default",{bgOpacity = 0,unlockCursor = false})


---Sets the current page to the one with the assigned name.
---@param name string?
function pageRizzler.setPage(name)
	if currentPage then
		currentPage.EXIT:invoke()
		currentPage.screen:free()
	end
	local nextPage = pages[name] or defaultPage
	history[#history+1] = name or "default"
	
	config:setName("PageRizzler")
	config:save(CONFIG_KEY,name or "default")
	
	pageRizzler.currentPage = name or "default"
	pageRizzler.PAGE_CHANGED:invoke(nextPage)
	
	if nextPage then
		local box = GNUI.newBox(screen)
		:setAnchor(0,0,1,1)
		:setNineslice(GNUI.newNineslice(background):setRenderType("TRANSLUCENT"):setColor(0,0,0):setOpacity(nextPage.bgOpacity or 0.5))
		nextPage.INIT:invoke(box)
		local hideHud = nextPage.bgOpacity > 0
		renderer:setRenderHUD(not hideHud)
		renderer:setRenderCrosshair(not hideHud)
 		host.unlockCursor = nextPage.unlockCursor
		nextPage.screen = box
		currentPage = nextPage
	end
end

function pageRizzler.returnPage()
	if #history > 0 then
		local i = #history
		table.remove(history,i)
		pageRizzler.setPage(history[i-1])
	end
end


---@param name string
---@return GNUI.page
function pageRizzler.getPage(name)
	return pages[name]
end


---Returns the page thats active by default.
---@return GNUI.page
function pageRizzler.getDefaultPage()
	return defaultPage
end


---@class GNUI.page
---@field name string
---@field screen GNUI.Box?
---@field bgOpacity number
---@field unlockCursor boolean
---@field INIT EventLib
---@field EXIT EventLib


events.ENTITY_INIT:register(function ()
	config:setName("PageRizzler")
	local page = config:load(CONFIG_KEY) or "default"
	pageRizzler.setPage(page)
end)

return pageRizzler