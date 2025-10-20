local simpleCollision = {}

simpleCollision.lookUp = {}
simpleCollision.partitions = {}
local PARTITION_SIZE = 400

--- WHEN "DELETING" COLLIDERS MAKE SURE TO REMOVE THE COLLIDER FROM ALL PARTITIONS and THE LOOK UP TABLES and ANY OTHER HARD REFERENCES THAT POINT TO IT

local function checkLayer(layerSettings, layer)
	if layerSettings == nil then
		return true
	end

	local mode = layerSettings.mode

	if mode == "whitelist" then
		for _, value in ipairs(layerSettings.layers) do
			if value == layer then
				return true
			end
		end
		return false
	end
	if mode == "blacklist" then
		for _, value in ipairs(layerSettings.layers) do
			if value == layer then
				return false
			end
		end
		return true
	end
end

local function getPossibleColliders(partitions, layerSettings)
	local colliders = {}

	for _, partition in ipairs(partitions) do
		for _, collider in pairs(partition) do
			if checkLayer(layerSettings, collider.layer) then
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

local function getPartitionsFromArea(topLeftPoint, bottomRightPoint)
	local topLeftPartition =
		Vector2.new(math.floor(topLeftPoint.x / PARTITION_SIZE), math.floor(topLeftPoint.y / PARTITION_SIZE))
	local bottomRightPartition =
		Vector2.new(math.floor(bottomRightPoint.x / PARTITION_SIZE), math.floor(bottomRightPoint.y / PARTITION_SIZE))

	local partitions = {}

	for x = topLeftPartition.x, bottomRightPartition.x, 1 do
		for y = topLeftPartition.y, bottomRightPartition.y, 1 do
			simpleCollision.partitions[x] = simpleCollision.partitions[x] or {}
			simpleCollision.partitions[x][y] = simpleCollision.partitions[x][y] or {}
			partitions[#partitions + 1] = simpleCollision.partitions[x][y]
		end
	end

	return partitions
end

function simpleCollision:setCollidersPartitions(collider)
	local bottomRightPoint, _, _, topLeftPoint = getColliderPoints(collider)

	for _, partition in ipairs(getPartitionsFromArea(topLeftPoint, bottomRightPoint)) do
		partition[collider] = collider
		simpleCollision.lookUp[collider] = simpleCollision.lookUp[collider] or {}
		simpleCollision.lookUp[collider][#simpleCollision.lookUp[collider] + 1] = partition
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
---@field super? table This is a table assigned when the collider is generated. It is an additional table that is returned when another collider collides with this one
local collisionMetaData = { position = nil, scale = nil, super = nil }
---@private
collisionMetaData.__index = collisionMetaData
---@private
collisionMetaData.layer = nil

function collisionMetaData:detectCollision(layer)
	local supers = {}
	for _, otherCollider in ipairs(getPossibleColliders(simpleCollision.lookUp[self], layer)) do
		if self ~= otherCollider then
			if checkOverlap(self, otherCollider) then
				supers[#supers + 1] = otherCollider.super
			end
		end
	end
	return #supers ~= 0, supers
end

function collisionMetaData:move(position)
	simpleCollision:removeCollidersPartitions(self)
	self.position = position
	simpleCollision:setCollidersPartitions(self)
end

function simpleCollision:update() end

---Detects collision along a line between start and _end
---@param start Vector
---@param _end Vector
---@param filteringSettings? table
function simpleCollision:checkLine(start, _end, filteringSettings)
	local lineAxis = (_end - start):normalized()
	lineAxis = Vector2.new(lineAxis.y, -lineAxis.x)
	local axisProjections = { lineAxis, Vector2.new(0, 1), Vector2.new(1, 0) }

	local topLeftPoint
	local bottomRightPoint

	if start.x < _end.x then
		topLeftPoint = start:copy()
		bottomRightPoint = _end:copy()
	else
		topLeftPoint = _end:copy()
		bottomRightPoint = start:copy()
	end
	if topLeftPoint.y > bottomRightPoint.y then
		local lowerYHeight = topLeftPoint.y
		topLeftPoint.y = bottomRightPoint.y
		bottomRightPoint.y = lowerYHeight
	end

	local partitions = getPartitionsFromArea(topLeftPoint, bottomRightPoint)

	for _, collider in ipairs(getPossibleColliders(partitions, filteringSettings)) do
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

			if lineMin > pointMax then
				isColliding = false
				break
			elseif lineMax < pointMin then
				isColliding = false
				break
			end
		end
		if isColliding then
			return true, collider.super
		end
	end
	return false
end

---Creates, registers, and returns a collider with the given values. Note: The collider is hard referenced in the collider library
---@param position Vector
---@param scale Vector
---@param super? table A value that gets returned when something collides with this collider. By default (nil) it will be the collider itself
---@param layer? string Determines on what layer the collider will exist on. Used for filtered collision detection
function simpleCollision:addCollider(position, scale, super, layer)
	layer = layer or "unorganized"
	local collider = {
		position = position,
		scale = scale,
		layer = layer,
		super = super or self,
	}

	self:setCollidersPartitions(collider)

	return setmetatable(collider, collisionMetaData)
end

---Detects collision within a specified square
---@param position Vector
---@param scale Vector
---@param filteringSettings? table Specifies the filtering settings used during collision detection. Used when wanting only specific objects to be detected
function simpleCollision:checkSquare(position, scale, filteringSettings)
	local collider = { position = position, scale = scale }
	local supers = {}
	local partitions =
		getPartitionsFromArea(collider.position - collider.scale / 2, collider.position + collider.scale / 2)

	for _, secondCollider in ipairs(getPossibleColliders(partitions, filteringSettings)) do
		if checkOverlap(collider, secondCollider) == true then
			supers[#supers + 1] = secondCollider.super
		end
	end
	return #supers ~= 0, supers
end

---Detects collision at a point
---@param position Vector
---@param filteringSettings? table
function simpleCollision:checkPoint(position, filteringSettings)
	local supers = {}
	local partition =
		{ self.partitions[math.floor(position.x / PARTITION_SIZE)][math.floor(position.y / PARTITION_SIZE)] }
	for _, collider in ipairs(getPossibleColliders(partition, filteringSettings)) do
		if
			position.x > collider.position.x - collider.scale.x / 2
			and position.x < collider.position.x + collider.scale.x / 2
		then
			if
				position.y > collider.position.y - collider.scale.y / 2
				and position.y < collider.position.y + collider.scale.y / 2
			then
				supers[#supers + 1] = collider.super
			end
		end
	end

	return #supers ~= 0, supers
end

function simpleCollision:drawColliders_Debug()
	love.graphics.push()
	love.graphics.setColor(1, 0, 0, 0.25)
	for x, collumn in pairs(self.partitions) do
		for y, row in pairs(collumn) do
			for _, v in pairs(row) do
				love.graphics.rectangle(
					"fill",
					v.position.x - v.scale.x / 2,
					v.position.y - v.scale.y / 2,
					v.scale.x,
					v.scale.y
				)
			end
		end
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
