--[[______   __
  / ____/ | / / By: GNamimates | https://gnon.top | Discord: @gn8.
 / / __/  |/ / A service library for handling which page should be displayed at the screen.
/ /_/ / /|  / 
\____/_/ |_/ Source: https://github.com/lua-gods/GNs-Avatar-3/blob/main/lib/pages.lua]]
-- DEPENDENCIES
local Macros = require"lib.macros"
local eventLib = require"lib.eventLib"
local GNUI = require"lib.GNUI.main"
local screen = GNUI.getScreenCanvas()


local BACKGROUND = textures["1x1white"] or textures:newTexture("1x1white",1,1):setPixel(0,0,vec(1,1,1))
local CONFIG_KEY = avatar:getName()..".lastPage"


---@class GNUI.page
---@field name string
---@field screen GNUI.Box?
---@field bgOpacity number
---@field unlockCursor boolean
---@field blur boolean
---@field macro Macro



local pages = {} ---@type table<string, GNUI.page>
local currentPage ---@type GNUI.page?
local history = {}

---@class GNUI.PageRizzler
local pageRizzler = {
	PAGE_CHANGED = eventLib.new(),
	pages = pages,
}


---@param name string
---@param config {bgOpacity:number?,unlockCursor:boolean?,blur:boolean}?
---@param init fun(events:Macro.Events, screen:GNUI.Box)?
---@return GNUI.page
function pageRizzler.newPage(name,config,init)
	config = config or {}
	local page = {
		bgOpacity = config.bgOpacity or 0.5,
		unlockCursor = not (config and config.unlockCursor ~= nil and not config.unlockCursor),
		blur = not (config and config.blur ~= nil and not config.blur),
	}
	if init then
		page.macro = Macros.new("Page."..name,init)
	end
	if pages[name] then error("page "..name.." already exists",2) end
	pages[name] = page
	return page
end


local defaultPage = pageRizzler.newPage("default",{bgOpacity = 0,unlockCursor = false})


---Sets the current page to the one with the assigned name.
---@param name string?
function pageRizzler.setPage(name)
	if currentPage then
		if currentPage.macro then
			currentPage.macro:setActive(false,currentPage.screen)
		end
		currentPage.screen:free()
	end
	local nextPage = pages[name] or defaultPage
	history[#history+1] = name or "default"
	
	config:setName("PageRizzler")
	config:save(CONFIG_KEY,name or "default")
	
	pageRizzler.currentPage = name or "default"
	pageRizzler.PAGE_CHANGED:invoke(nextPage)
	
	if nextPage then
		local subScreen = GNUI.newBox(screen)
		:setAnchor(0,0,1,1)
		:setNineslice(GNUI.newNineslice(BACKGROUND):setRenderType("TRANSLUCENT"):setColor(0,0,0):setOpacity(nextPage.bgOpacity or 0.5))
		if nextPage and nextPage.macro then
			nextPage.macro:setActive(true,subScreen)
		end
		local hideHud = nextPage.bgOpacity > 0
		
		--if BLUR_BACKGROUND then
		--   pcall(renderer.postEffect,renderer,(hideHud and nextPage.blur) and "blur" or nil)
		--end
		renderer:setRenderHUD(not hideHud)
		renderer:setRenderCrosshair(not hideHud)
		if goofy then
			goofy:setDisableGUIElement("CHAT", hideHud)
		end
		host.unlockCursor = nextPage.unlockCursor
		nextPage.screen = subScreen
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





events.ENTITY_INIT:register(function ()
	config:setName("PageRizzler")
	local page = config:load(CONFIG_KEY) or "default"
	pageRizzler.setPage(page)
end)


return pageRizzler