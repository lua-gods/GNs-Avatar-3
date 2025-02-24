

local Macros = require("scriptHost.macros")


return Macros.new("Shadow Mayhem",function (macro)
	local shadow = models.player:copy("Shadowerer")
	:setParentType("WORLD")
	:setColor(0,0,0)
	:scale(1,0,1)
	models:addChild(shadow)
	renderer:setShadowRadius(0)
	
	function macro.RENDER(deltaTick)
		if not player:isLoaded() then return end
		local dayTime = (((world.getTimeOfDay()) % 24000) / 24000 - 0.25) % 1
    	local sunAngle = (dayTime * 2 + (0.5 - math.cos(dayTime * math.pi) / 2)) / 3 * 360
		 local shift = math.tan(math.rad((sunAngle%180)))
		local ppos = player:getPos(deltaTick)
		local _,floor = raycast:block(ppos,ppos-vec(-shift*10,10,0),"COLLIDER","NONE")
		local mat = matrices.mat4()
		mat:scale(1,0,1):rotateY(180-player:getBodyYaw(deltaTick)):translate((floor*16):add(0,0.3,0))
		mat.c2 = mat.c2._yzw + vec(shift,0,0,0)
		shadow:setMatrix(mat)
	end
	
	function macro.EXIT()
		renderer:setShadowRadius()
		shadow:remove()
	end
end,true),"Duplicates the player modelPart and squishes it onto the ground"