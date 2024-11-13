--[[______   __
  / ____/ | / / by: GNamimates, Discord: "@gn8.", Youtube: @GNamimates
 / / __/  |/ / A service library for handling which page should be displayed at the screen.
/ /_/ / /|  / 
\____/_/ |_/ Source: link]]

local eventLib = require"libraries.eventLib"
local GNUI = require"GNUI.main"
local screen = GNUI.getScreenCanvas()

local background = textures["1x1white"] or textures:newTexture("1x1white",1,1):setPixel(0,0,vec(1,1,1))

---@class GNUI.PageRizzler
local pageRizzler = {}
local pages = {} ---@type table<string, GNUI.page>
local currentPage ---@type GNUI.page?

---@param name string
---@param bgOpacity number?
function pageRizzler.newPage(name,bgOpacity)
	local page = {
		bgOpacity = bgOpacity,
		INIT = eventLib.new(),
		EXIT = eventLib.new(),
	}
	if pages[name] then error("page "..name.." already exists") end
	pages[name] = page
	return page
end


local defaultPage = pageRizzler.newPage("default",0)


---Sets the current page to the one with the assigned name.
---@param name string?
function pageRizzler.setPage(name)
	if currentPage then
		currentPage.EXIT:invoke()
		currentPage.screen:free()
	end
	local nextPage = pages[name] or defaultPage
	if nextPage then
		local box = GNUI.newBox(screen)
		:setAnchor(0,0,1,1)
		:setNineslice(GNUI.newNineslice(background):setRenderType("TRANSLUCENT"):setColor(0,0,0):setOpacity(nextPage.bgOpacity or 0.5))
		nextPage.INIT:invoke(box)
		renderer:setRenderHUD(nextPage.bgOpacity == 0)
		nextPage.screen = box
		currentPage = nextPage
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
---@field INIT EventLib
---@field EXIT EventLib

pageRizzler.setPage("default")

return pageRizzler