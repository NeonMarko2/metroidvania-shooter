local simpleCollision = {}

simpleCollision.world = {}
simpleCollision.lookUp = {}
simpleCollision.partitions = {}
local PARTITION_SIZE = 400

local function checkLayer(layer, layerIndex)
	if layer == nil then
		return true
	end

	local mode = layer.mode

	if mode == "whitelist" then
		for _, value in ipairs(layer.layers) do
			if value == layerIndex then
				return true
			end
		end
		return false
	end
	if mode == "blacklist" then
		for _, value in ipairs(layer.layers) do
			if value == layerIndex then
				return false
			end
		end
		return true
	end
end

local function getPossibleColliders(collider, layer)
	local colliders = {}

	local partitionsToCheck = simpleCollision.lookUp[collider]

	for _, partition in ipairs(partitionsToCheck) do
		for index, collider in pairs(partition) do
			if checkLayer(layer, collider.layer) then
				colliders[#colliders + 1] = collider
			end
		end
	end

	return colliders
end

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

local function getColliderPoints(collider)
	local point1 = collider.position + Vector2.new(collider.scale.x, collider.scale.y) / 2
	local point2 = collider.position + Vector2.new(collider.scale.x, -collider.scale.y) / 2
	local point3 = collider.position + Vector2.new(-collider.scale.x, collider.scale.y) / 2
	local point4 = collider.position + Vector2.new(-collider.scale.x, -collider.scale.y) / 2
	return point1, point2, point3, point4
end

function simpleCollision:setCollidersPartitions(collider)
	local bottomRightPoint, _, _, topLeftPoint = getColliderPoints(collider)
	local points = { getColliderPoints(collider) }

	local topLeftPartition =
		Vector2.new(math.floor(topLeftPoint.x / PARTITION_SIZE), math.floor(topLeftPoint.y / PARTITION_SIZE))
	local bottomRightPartition =
		Vector2.new(math.floor(bottomRightPoint.x / PARTITION_SIZE), math.floor(bottomRightPoint.y / PARTITION_SIZE))

	for x = topLeftPartition.x, bottomRightPartition.x, 1 do
		for y = topLeftPartition.y, bottomRightPartition.y, 1 do
			simpleCollision.partitions[x] = simpleCollision.partitions[x] or {}
			simpleCollision.partitions[x][y] = simpleCollision.partitions[x][y] or {}
			simpleCollision.partitions[x][y][collider] = collider
			simpleCollision.lookUp[collider] = simpleCollision.lookUp[collider] or {}
			simpleCollision.lookUp[collider][#simpleCollision.lookUp[collider] + 1] = simpleCollision.partitions[x][y]
		end
	end
end

function simpleCollision:removeCollidersPartitions(collider)
	local collidersPartitions = simpleCollision.lookUp[collider]
	if collidersPartitions == nil then
		error("Trying to remove collider partitions, but collider isnt established in any partitions")
	end
	for _, partition in pairs(collidersPartitions) do
		partition[collider] = nil
	end
end

---@class Collider
---@field position Vector
---@field scale Vector
local collisionMetaData = { position = nil, scale = nil }
---@private
collisionMetaData.__index = collisionMetaData
---@private
collisionMetaData.layer = nil

function collisionMetaData:detectCollision(layer)
	for _, otherCollider in ipairs(getPossibleColliders(self, layer)) do
		if self ~= otherCollider then
			if checkOverlap(self, otherCollider) then
				return true
			end
		end
	end
	return false
end

function collisionMetaData:move(position)
	simpleCollision:removeCollidersPartitions(self)
	self.position = position
	simpleCollision:setCollidersPartitions(self)
end

function simpleCollision:update() end

---@param start Vector
---@param _end Vector
function simpleCollision:checkLine(start, _end)
	local lineAxis = (_end - start):normalized()
	lineAxis = Vector2.new(lineAxis.y, -lineAxis.x)
	local axisProjections = { lineAxis, Vector2.new(0, 1), Vector2.new(1, 0) }
	for _, collider in ipairs(getPossibleColliders()) do
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
function simpleCollision:addCollider(position, scale, isStatic, layer)
	layer = layer or "unorganized"
	local collider = {
		position = position,
		scale = scale,
		layer = layer,
	}

	self:setCollidersPartitions(collider)

	self.world[#self.world + 1] = collider

	return setmetatable(collider, collisionMetaData)
end

function simpleCollision:checkSquare(position, scale, layerIndex)
	local collider = { position = position, scale = scale }
	for _, secondCollider in ipairs(getPossibleColliders(collider)) do
		if checkOverlap(collider, secondCollider) == true then
			return true
		end
	end
	return false
end

function simpleCollision:checkPoint(position)
	for _, collider in ipairs(getPossibleColliders()) do
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
	for i, v in pairs(self.world) do
		love.graphics.rectangle(
			"fill",
			v.position.x - v.scale.x / 2,
			v.position.y - v.scale.y / 2,
			v.scale.x,
			v.scale.y
		)
	end

	for x, collumn in pairs(simpleCollision.partitions) do
		for y, partition in pairs(collumn) do
			local count = 0
			for _, colllider in pairs(partition) do
				count = count + 1
			end
			love.graphics.setColor(1, 1, 1, 0.2 * count)
			love.graphics.rectangle("fill", x * PARTITION_SIZE, y * PARTITION_SIZE, PARTITION_SIZE, PARTITION_SIZE)
			love.graphics.print(
				count,
				x * PARTITION_SIZE + (PARTITION_SIZE / 2),
				y * PARTITION_SIZE + (PARTITION_SIZE / 5)
			)
		end
	end

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.pop()
end

return simpleCollision
