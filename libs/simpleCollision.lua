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

local collisionMetaData = {}
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

function simpleCollision:checkPoint() end

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
