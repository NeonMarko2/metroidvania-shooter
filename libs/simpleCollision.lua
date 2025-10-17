local simpleCollision = {}

simpleCollision.world = {}

local function checkOverlap(collider1, collider2)
	if
		collider1.position.x + collider1.scale.x / 2 > collider2.position.x - collider2.scale.x / 2
		and collider1.position.x - collider1.scale.x / 2 < collider2.position.x + collider2.scale.x / 2
	then
		if
			collider1.position.y + collider1.scale.y / 2 > collider2.position.y - collider2.scale.y / 2
			and collider1.position.y - collider1.scale.y / 2 < collider2.position.y + collider2.scale.y / 2
		then
			return true
		end
	end
	return false
end

---@class Collider
---@field position Vector
---@field scale Vector
local collisionMetaData = { position = nil, scale = nil }
---@private
collisionMetaData.__index = collisionMetaData

function collisionMetaData:detectCollision()
	for _, otherCollider in ipairs(Collision.world) do
		if self ~= otherCollider then
			if checkOverlap(self, otherCollider) then
				return true
			end
		end
	end
	return false
end

function simpleCollision:update() end

local function getColliderPoints(collider)
	local point1 = collider.position + Vector2.new(collider.scale.x, collider.scale.y) / 2
	local point2 = collider.position + Vector2.new(collider.scale.x, -collider.scale.y) / 2
	local point3 = collider.position + Vector2.new(-collider.scale.x, collider.scale.y) / 2
	local point4 = collider.position + Vector2.new(-collider.scale.x, -collider.scale.y) / 2
	return point1, point2, point3, point4
end

---@param start Vector
---@param _end Vector
function simpleCollision:checkLine(start, _end)
	local lineAxis = (_end - start):normalized()
	lineAxis = Vector2.new(lineAxis.y, -lineAxis.x)
	local axisProjections = { lineAxis, Vector2.new(0, 1), Vector2.new(1, 0) }
	for _, collider in ipairs(self.world) do
		local points = { getColliderPoints(collider) }
		local isColliding = true
		for _, axis in ipairs(axisProjections) do
			local pointMin, pointMax = 99999, -99999
			for _, point in pairs(points) do
				local pointDotProduct = point:dot(axis)
				pointMin = math.min(pointDotProduct, pointMin)
				pointMax = math.max(pointDotProduct, pointMax)
			end
			local lineMin = math.min(start:dot(axis), _end:dot(axis))
			local lineMax = math.max(start:dot(axis), _end:dot(axis))
			print(lineMin .. " " .. lineMax .. " | " .. pointMin .. " " .. pointMax)

			if lineMin > pointMax then
				isColliding = false
				break
			elseif lineMax < pointMin then
				isColliding = false
				break
			end
		end
		if isColliding then
			return true
		end
	end
	return false
end

---@param position Vector
---@param scale Vector
function simpleCollision:addCollider(position, scale, isStatic)
	local collider = {
		position = position,
		scale = scale,
	}
	self.world[#self.world + 1] = collider
	return setmetatable(collider, collisionMetaData)
end

function simpleCollision:checkSquare(position, scale, layerIndex)
	local collider = { position = position, scale = scale }
	for _, secondCollider in ipairs(self.world) do
		if checkOverlap(collider, secondCollider) == true then
			return true
		end
	end
	return false
end

function simpleCollision:checkPoint(position)
	for _, collider in ipairs(self.world) do
		if
			position.x > collider.position.x - collider.scale.x / 2
			and position.x < collider.position.x + collider.scale.x / 2
		then
			if
				position.y > collider.position.y - collider.scale.y / 2
				and position.y < collider.position.y + collider.scale.y / 2
			then
				return true
			end
		end
	end
	return false
end

function simpleCollision:drawColliders_Debug()
	love.graphics.push()
	love.graphics.setColor(1, 0, 0, 0.25)
	for i, v in ipairs(self.world) do
		love.graphics.rectangle(
			"fill",
			v.position.x - v.scale.x / 2,
			v.position.y - v.scale.y / 2,
			v.scale.x,
			v.scale.y
		)
	end
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.pop()
end

return simpleCollision
