local GNUI = require("lib.GNUI.main")
local Button = require"lib.GNUI.element.button"
local Slider = require"lib.GNUI.element.slider"

local quickTween = require"scriptHost.ui.quickTween"
local Pages = require"lib.pages"

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
			local maxResY = resolution.y - 1
			local halfMaxResY = maxResY * 0.5
			local z = resolution.x*0.5-resolution.y*0.5 + 1 * halfMaxResY
			local vectors_angleToDir = vectors.angleToDir
			local renderSize2_x, renderSize2_y = -360 / renderSize.x, 180 / renderSize.y
			local math_abs = math.abs
			local math_max = math.max
			local facesRight, facesLeft = faces.right, faces.left
			local facesTop, facesBottom = faces.top, faces.bottom
			local facesFront, facesBack = faces.front, faces.back
			local time = client.getSystemTime()
			repeatUntiltrue(function () -->====================[ RENDERING ]====================<--
				local dir = vectors_angleToDir(y*renderSize2_y-90,x*renderSize2_x-180)
				local axis_x, axis_y = math_abs(dir.x), math_abs(dir.y)
				local maxAxis = math_max(axis_x, axis_y, math_abs(dir.z))
				if maxAxis == axis_x then
					if dir.x > 0 then
						local uv = dir.zy / -dir.x
						renderTexture:setPixel(x,y,facesRight:getPixel(uv.x * halfMaxResY + z, (uv.y + 1) * halfMaxResY))
					else
						local uv = dir.zy / dir.x
						renderTexture:setPixel(x,y,facesLeft:getPixel(-uv.x * halfMaxResY + z, (uv.y + 1) * halfMaxResY))
					end
				elseif maxAxis == axis_y then
					if dir.y > 0 then
						local uv = dir.xz / dir.y
						renderTexture:setPixel(x,y,facesTop:getPixel(uv.x * halfMaxResY + z, (uv.y + 1) * halfMaxResY))
					else
						local uv = dir.xz / dir.y
						renderTexture:setPixel(x,y,facesBottom:getPixel(-uv.x * halfMaxResY + z, (uv.y + 1) * halfMaxResY))
					end
				else
					if dir.z > 0 then
						local uv = dir.xy / -dir.z
						renderTexture:setPixel(x,y,facesFront:getPixel(-uv.x * halfMaxResY + z, (uv.y + 1) * halfMaxResY))
					else
						local uv = dir.xy / dir.z
						renderTexture:setPixel(x,y,facesBack:getPixel(uv.x * halfMaxResY + z, (uv.y + 1) * halfMaxResY))
					end
				end
				
				x = x + 1
				if renderSize.x <= x then
					x = 0
					y = y + 1
					if y % 10 == 0 then
						renderTexture:update()
					end
					if renderSize.y <= y then
						renderTexture:update()
						print('Rendered in:', (client.getSystemTime() - time) / 1000)
						return true
					end
				end
			end,1000,
		function () -->====================[ SAVING ]====================<--
			if not file:isDirectory("panoramas") then file:mkdir("panoramas") end
			local fileIMin, fileIMax = 1, 2 ^ 32
			for _ = 1, 33 do
				if fileIMax == fileIMin then break end
				local middle = math.floor((fileIMin + fileIMax) * 0.5)
				if file:isFile("panoramas/PANO_"..middle..".png") then
					fileIMin = middle + 1
				else
					fileIMax = middle
				end
			end
			local path = "panoramas/PANO_"..fileIMin..".png"
			if not file:isFile(path) then
				local write = file:openWriteStream(path)
				local content = renderTexture:save()
				local buff = data:createBuffer(#content)
				buff:writeBase64(content)
				buff:setPosition(0)
				buff:writeToStream(write)
				buff:close()
				write:close()
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