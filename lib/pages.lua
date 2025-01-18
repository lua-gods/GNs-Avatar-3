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

local BLUR_BACKGROUND = true

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
---@return GNUI.page
function pageRizzler.newPage(name,config)
	config = config or {}
	local page = {
		bgOpacity = config.bgOpacity or 0.5,
		unlockCursor = not (config and config.unlockCursor ~= nil and not config.unlockCursor),
		blur = not (config and config.blur ~= nil and not config.blur),
		INIT = eventLib.new(),
		EXIT = eventLib.new(),
		TICK = eventLib.new(),
		RENDER = eventLib.new(),
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
		
		if BLUR_BACKGROUND then
		   pcall(renderer.postEffect,renderer,(hideHud and nextPage.blur) and "blur" or nil)
		end
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
---@field blur boolean
---@field INIT EventLib
---@field EXIT EventLib
---@field TICK EventLib
---@field RENDER EventLib


events.ENTITY_INIT:register(function ()
	config:setName("PageRizzler")
	local page = config:load(CONFIG_KEY) or "default"
	pageRizzler.setPage(page)
end)

events.WORLD_TICK:register(function ()
	if currentPage then currentPage.TICK:invoke(currentPage.screen) end
end)

local lastSystemTime = client:getSystemTime()
events.WORLD_RENDER:register(function (delta)
	local systemTime = client:getSystemTime()
	local deltaFrame = (systemTime - lastSystemTime) / 1000
	if currentPage then currentPage.RENDER:invoke(currentPage.screen,delta,deltaFrame) end
end)

return pageRizzler