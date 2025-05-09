local Macros = require("scriptHost.macros")

local face2dir = {
   ["north"] = vectors.vec3(0,0,-1),
   ["east"]  = vectors.vec3(1,0,0),
   ["south"] = vectors.vec3(0,0,1),
   ["west"]  = vectors.vec3(-1,0,0),
   ["up"]    = vectors.vec3(0,1,0),
   ["down"]  = vectors.vec3(0,-1,0),
}

local offsetLookup = {
	wall = 0.5,
	ceiling = 0.99,
	floor = 0.05
}

return Macros.new("ButtonAsEntireSurface",function (events)
   function events.POST_WORLD_RENDER()
		if player:isLoaded() then
			local _,hit,side = player:getTargetedBlock(true,5)
			local dir = face2dir[side]
			local block = world.getBlockState(hit+dir*0.1)
			if block.id:find("button") or block.id:find("lever") then
				local offset = (block.properties.face == "wall" and -face2dir[block.properties.facing] or vec(0,0,0)) * 0.45 + vec(0.5,0,0.5) + vec(0,offsetLookup[block.properties.face] or 0,0)
				renderer:setEyeOffset(block:getPos():add(offset)-player:getPos():add(0,player:getEyeHeight()))
			end
		end
	end
end),"Makes it so the hitbox of the button extends to the entire surface it is attatched to"