local vector2 = {}

---@class vectorBase
local vectorBase = {}

local function addVectors(a, b)
	if (a.x and b.x) and (a.y and b.y) then
		a.x = a.x + b.x
		a.y = a.y + b.y
		return a
	else
		error("Trying to add non vectors together")
	end
end

local function subVectors(a, b)
	if (a.x and b.x) and (a.y and b.y) then
		a.x = a.x - b.x
		a.y = a.y - b.y
		return a
	else
		error("Trying to subtract non vectors together")
	end
end

local function multiplyVector(a, b)
	if type(a) == "number" and type(b) == "table" then
		local c = a
		a = b
		b = c
	end
	if type(b) ~= "number" then
		error("Cant multiply vector by non numbers")
	end

	a.x = a.x * b
	a.y = a.y * b

	return a
end

local function divideVector(a, b)
	if type(b) ~= "number" then
		error("Cant divide vector by non numbers")
	end

	a.x = a.x / b
	a.y = a.y / b

	return a
end

local function tableToString(table)
	return "x: " .. table.x .. ",   y: " .. table.y .. " "
end

function vectorBase:magnitude()
	local x, y = 0, 0
	x = self.x * self.x
	y = self.y * self.y
	return math.sqrt(x + y)
end

---Normalizes the calling vector,
---turning it into a unit vector
function vectorBase:normalized()
	local magnitude = self:magnitude()
	return vector2.new(self.x / magnitude, self.y / magnitude)
end

---@private
vectorBase.__add = addVectors
---@private
vectorBase.__sub = subVectors
---@private
vectorBase.__mul = multiplyVector
---@private
vectorBase.__div = divideVector
---@private
vectorBase.__tostring = tableToString
---@private
vectorBase.__index = vectorBase

---@param xPos number
---@param yPos number
function vector2.new(xPos, yPos)
	local vector = { x = xPos, y = yPos }

	return setmetatable(vector, vectorBase)
end

return vector2
