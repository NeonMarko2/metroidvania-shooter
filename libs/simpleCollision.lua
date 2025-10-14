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

function simpleCollision:update()
	for index, collider in ipairs(self.world) do
		for _, secondCollider in ipairs(self.world) do
		end
	end
end

function simpleCollision:addCollider(position, scale, isStatic)
	local collider = { position = position, scale = scale }
	self.world[#self.world + 1] = collider
	return collider
end

function simpleCollision:checkSquare() end

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
