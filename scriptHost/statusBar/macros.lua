---@diagnostic disable: lowercase-global
local GNUI = require("GNUI.main")
-- GNUI Modules
local Elements = require("GNUI.modules.elements")
local Window = require("GNUI.modules.windows")
local Themes = require("GNUI.modules.themes")
-- Screen Stuffs
local screen = GNUI.getScreenCanvas()
local Statusbar = require("scriptHost.statusbar")
local icon = GNUI.newSprite():setTexture(textures["textures.icons"]):setUV(82,42,97,55)

local button = Statusbar.newButtonSprite("Macros",icon)

local window = Window.newWindow(true)
window.CLOSE_REQUESTED:register(function ()window:setVisible(false)end)
button.PRESSED:register(function ()window:setVisible(true) end)
window:setTitle("Macros")

window:setPos(16,16):setSize(150,200)

local slider = Elements.newScrollbarButton()
slider:setAnchor(1,0,1,1):setDimensions(-8,0,0,0)

local outliner = Elements.newStack()
outliner:setAnchor(0,0,1,1):setDimensions(0,0,-7,0)
outliner:setMargin(-1)
outliner:setContainChildren(false)
slider.ON_SCROLL:register(function (p)
   local y = p * 15
   outliner:setChildrenShift(0,y)
end)
window:addElement(outliner)

local lastSystemTime = client:getSystemTime()
local deltaFrame = 0
events.WORLD_RENDER:register(function ()
   local systemTime = client:getSystemTime()
   deltaFrame = (systemTime - lastSystemTime) / 100
   lastSystemTime = systemTime
end)

---@type table<string,{tick:fun(),render:fun(delta_frame:number),run:fun(),stop:fun()}>
local macros = {}
local count = 0
local function newMaro(name,m)
   config:setName("GNv6 Macros Remember")
   local enabled = config:load(name) or false
   local started = false
   local self = GNUI.newContainer()
   
   self:setClipOnParent(true)
   self:setCustomMinimumSize(16,16)
   outliner:addChild(self)
   
   local toggle = Elements.newTextButton()
   toggle:setAnchor(1,0,1,1):setDimensions(-48,0,0,2)
   local title = GNUI.newLabel()
   title:setAnchor(0,0,1,1):setDimensions(0,0,0,0)
   title:setText(name):setAlign(0,0.5)
   
   local function onToggle()
      if enabled then
         if m.run then
            m.run()
         end
         if m.tick then events.WORLD_TICK:register(function () if player:isLoaded() then m.tick() end end,"macro."..name)end
         if m.render then events.WORLD_RENDER:register(function ()m.render(deltaFrame)end,"macro."..name)end
         toggle:setText({text="True",color="dark_green"})
         started = true
      else
         events.WORLD_TICK:remove("macro."..name)
         events.WORLD_RENDER:remove("macro."..name)

         if m.stop and started then
            m.stop()
         end
         toggle:setText({text="False",color="dark_red"})
      end
   end
   onToggle()
   
   toggle.PRESSED:register(function ()
      enabled = not enabled
      config:save(name,enabled)
      onToggle()
   end)
   self:addChild(title)
   self:addChild(toggle)
   
   count = count + 1
   slider:setRange(0,count)
end

---@type {tick:fun(),render:fun(delta_frame:number),run:fun(),stop:fun()}
macro = {}

for _, path in pairs(listFiles("macros",false)) do
   local name = ("."..path):match("([^.]+)$")
   require(path)
   macros[name] = macro
   newMaro(name,macro)
   macro = {}
end

window:setVisible(false)

window:addElement(slider)
screen:addChild(window)