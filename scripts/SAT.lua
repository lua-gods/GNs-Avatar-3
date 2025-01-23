
local modelWorld = models:newPart("SATWorld","WORLD")

local points = {}

for z = -0.5, 0.5, 1 do
	for y = -0.5, 0.5, 1 do
		for x = -0.5, 0.5, 1 do
			table.insert(points, vec(x, y, z))
		end
	end
end

---@param matrix Matrix4
local function toModelMatrix(matrix)
	local copy = matrix:copy() * matrices.mat4():translate(-0.5,-0.5,-0.5)
	copy.c4 = (copy.c4.xyz * 16):augmented()
	return copy
end


local offset = vec(628,65,-113)

local cubeA = matrices.mat4()
local cubeB = matrices.mat4()

cubeA
:translate(offset)
:translate(0,1,0.5)

cubeB
:rotate(15,45,45)
:translate(offset)
:translate(0.25,-0.1,0.5)
--:translate(0.25,2.2,0.5)


modelWorld:newBlock("cubeA"):block("minecraft:light_blue_stained_glass"):setMatrix(toModelMatrix(cubeA))
modelWorld:newBlock("cubeB"):block("minecraft:orange_stained_glass"):setMatrix(toModelMatrix(cubeB))


local cubeApos = cubeA:apply(0,0,0)
local cubeAmin = math.huge
local cubeAmax = -math.huge
for _, p in pairs(points) do
	local w = utils.closestPointOnAxis(cubeA:apply(p), cubeApos, cubeA:applyDir(0,1,0))
	cubeAmin = math.min(cubeAmin,w)
	cubeAmax = math.max(cubeAmax,w)
end

local cubeBpos = cubeB:apply(0,0,0)
local cubeBmin = math.huge
local cubeBmax = -math.huge
for _, p in pairs(points) do
	local w = utils.closestPointOnAxis(cubeB:apply(p), cubeApos, cubeA:applyDir(0,1,0))
	cubeBmin = math.min(cubeBmin,w)
	cubeBmax = math.max(cubeBmax,w)
end

utils.lineDisplayMatrix(cubeA)
utils.lineDisplayMatrix(cubeB)

print("collective reprojections:",cubeAmin, cubeAmax, cubeBmin, cubeBmax)
print("check intersections:",(cubeAmin - cubeBmax), (cubeBmin - cubeAmax))
print("spotted intersection:",math.max((cubeAmin - cubeBmax), (cubeBmin - cubeAmax)))