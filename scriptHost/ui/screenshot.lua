local GNUI = require("lib.GNUI.main")
local Button = require"lib.GNUI.element.button"
local Slider = require"lib.GNUI.element.slider"


local quickTween = require"scriptHost.ui.quickTween"
local Pages = require"lib.pages"

---@param rayDir Vector3
---@param planeDir Vector3
---@return Vector3?
local function ray2plane(rayDir, planeDir)
   rayDir = rayDir:normalize()
   planeDir = planeDir:normalize()
   local dot = rayDir:dot(planeDir)
   local t = (planeDir):dot(planeDir) / dot
   local intersection = rayDir * t
   return intersection
end


Pages.newPage(
"screenshot",
{bgOpacity=0.01,blur=false},
function (events, screen)
	local returnButton = Button.new(screen)
	:setPos(10,10):setSize(11,11):setText("x"):setTextOffset(0.5,-1.5)
	returnButton.PRESSED:register(function ()Pages.returnPage()end)
	
	local controls = GNUI.newBox(screen)
	:setAnchorMax()
	
	
	local Hslider = Slider.new(controls,{min=0,max=360,value=0,isVertical=false,step=10,showNumber=true,loop=true})
	:setAnchor(0,1,1,1)
	:setPos(10,-20)
	:setSize(-30,10)
	:setValue(client:getCameraRot().y % 360)
	
	
	local function screenshot()
		GNUI.getScreenCanvas():setVisible(false)
		local o = Hslider.value
		local faces = {}
		renderer:setRenderHUD(false)
		renderer:setFOV(90 / client:getFOV())
		renderer:setCameraRot(0,o)
		wait(250,function ()
			faces.front = host:screenshot("front")
		wait(100,function ()
			renderer:setCameraRot(0,o+90,0)
		wait(100,function ()
			faces.right = host:screenshot("right")
		wait(100,function ()
			renderer:setCameraRot(0,o+180,0)
		wait(100,function ()
			faces.back = host:screenshot("back")
		wait(100,function ()
			renderer:setCameraRot(0,o-90,0)
		wait(100,function ()
			faces.left = host:screenshot("left")
		wait(100,function ()
			renderer:setCameraRot(-90,o,0)
		wait(100,function ()
			faces.top = host:screenshot("top")
		wait(100,function ()
			renderer:setCameraRot(90,o,0)
		wait(100,function ()
			faces.bottom = host:screenshot("bottom")
		wait(20,function ()
			renderer:setFOV()
			renderer:setRenderHUD()
			renderer:setCameraRot(0,o,0)
			GNUI.getScreenCanvas():setVisible(true)
		wait(1,function ()
			local renderSize = vec(1024,512)
			local renderTexture = textures.renderTexture or textures:newTexture("renderTexture",renderSize.x,renderSize.y)
			local previewBox = GNUI.newBox(screen):setAnchor(0.5,0.5)
			:setSize(renderSize.x/renderSize.y*128,128)
			:setPos(renderSize.x/renderSize.y*-64,-64)
			quickTween.zoom(previewBox,50)
			previewBox:setNineslice(GNUI.newNineslice(renderTexture))
			local x,y = 0,0
			local resolution = faces.front:getDimensions()
			local z = resolution.x*0.5-resolution.y*0.5
			repeatUntiltrue(function () -->====================[ RENDERING ]====================<--
				local dir = vectors.angleToDir(y/renderSize.y*180-90,x/renderSize.x*-360-180)
				local sign_dir = vectors.vec3()
				local axis = {x = math.abs(dir.x), y = math.abs(dir.y), z = math.abs(dir.z)}
				local maxAxis = math.max(axis.x, axis.y, axis.z)
				if maxAxis == axis.x then
					sign_dir.x = math.sign(dir.x)
				elseif maxAxis == axis.y then
					sign_dir.y = math.sign(dir.y)
				else
					sign_dir.z = math.sign(dir.z)
				end
				if sign_dir.x == 1 and sign_dir.y == 0 and sign_dir.z == 0 then
					local uv = ray2plane(dir,vectors.vec3(1,0,0))
					renderTexture:setPixel(x,y,faces.right:getPixel(math.map(uv.z,1,-1,0,(resolution.y-1)) + z,math.map(uv.y,1,-1,0,(resolution.y-1))))
				elseif sign_dir.x == 0 and sign_dir.y == 0 and sign_dir.z == 1 then
					local uv = ray2plane(dir,vectors.vec3(0,0,1))
					renderTexture:setPixel(x,y,faces.front:getPixel(math.map(uv.x,-1,1,0,(resolution.y-1)) + z,math.map(uv.y,1,-1,0,(resolution.y-1))))
				elseif sign_dir.x == -1 and sign_dir.y == 0 and sign_dir.z == 0 then
					local uv = ray2plane(dir,vectors.vec3(-1,0,0))
					renderTexture:setPixel(x,y,faces.left:getPixel(math.map(uv.z,-1,1,0,(resolution.y-1)) + z,math.map(uv.y,1,-1,0,(resolution.y-1))))
				elseif sign_dir.x == 0 and sign_dir.y == 0 and sign_dir.z == -1 then
					local uv = ray2plane(dir,vectors.vec3(0,0,-1))
					renderTexture:setPixel(x,y,faces.back:getPixel(math.map(uv.x,1,-1,0,(resolution.y-1)) + z,math.map(uv.y,1,-1,0,(resolution.y-1))))
				elseif sign_dir.x == 0 and sign_dir.y == 1 and sign_dir.z == 0 then
					local uv = ray2plane(dir,vectors.vec3(0,1,0))
					renderTexture:setPixel(x,y,faces.top:getPixel(math.map(-uv.x,1,-1,0,(resolution.y-1)) + z,math.map(-uv.z,1,-1,0,(resolution.y-1))))
				elseif sign_dir.x == 0 and sign_dir.y == -1 and sign_dir.z == 0 then
					local uv = ray2plane(dir,vectors.vec3(0,-1,0))
					renderTexture:setPixel(x,y,faces.bottom:getPixel(math.map(-uv.x,1,-1,0,(resolution.y-1)) + z,math.map(uv.z,1,-1,0,(resolution.y-1))))
				end
				
				x = x + 1
				if renderSize.x <= x then
					x = 0
					y = y + 1
					if renderSize.y <= y then
						return true
					end
				end
				
				renderTexture:update()
			end,1000,
		function () -->====================[ SAVING ]====================<--
			if not file:isDirectory("panoramas") then file:mkdir("panoramas") end
			for i = 1, 10000, 1 do
				local path = "panoramas/PANO_"..i..".png"
				if not file:isFile(path) then
					local write = file:openWriteStream(path)
					local content = renderTexture:save()
					host:setClipboard(content)
					local buff = data:createBuffer(#content)
					buff:writeBase64(content)
					buff:setPosition(0)
					buff:writeToStream(write)
					buff:close()
					write:close()
					break
				end
			end
		end)
		
		end)end)end)
		end)
		end)end)end)
		end)end)end)
		end)	  end)
	
	end)
	end
	
	Button.new(controls):setAnchor(0,0):setText("Screenshot")
	:setPos(30,10)
	:setSize(100,11)
	.PRESSED:register(screenshot)
	
	
	local function updateCameraRot()
		renderer:setCameraRot(0,Hslider.value)
	end
	
	Hslider.VALUE_CHANGED:register(function () updateCameraRot() end)
	updateCameraRot()
	renderer:setRenderRightArm(false)
	renderer:setRenderLeftArm(false)
	
	function events.EXIT()
		renderer:setFOV()
		renderer:setCameraRot()
		renderer:setRenderLeftArm()
		renderer:setRenderRightArm()
	end
end)