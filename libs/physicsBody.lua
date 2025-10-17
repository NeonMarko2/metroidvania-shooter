local physicsBody = {}

---@class Body
local bodyMetaData = {}

---@private
bodyMetaData.__index = bodyMetaData

---move() will attempt to move the body to a spot if it is unoccupied
---@param newPosition Vector The position the body will attempt to move to.
---@return boolean wasSuccessful
function bodyMetaData:move(newPosition)
	local previousPosition = Vector2.new(self.collider.position.x, self.collider.position.y)
	self.collider.position = newPosition
	if self.collider:detectCollision() then
		self.collider.position = previousPosition
		return false
	end

	return true
end

function bodyMetaData:throw(newVelocity)
	self.velocity = newVelocity
end

---@param dt number delta time
function bodyMetaData:update(dt)
	if not self:move(self.collider.position + Vector2.new(0, self.velocity.y) * dt) then
		self.velocity.y = 0
	end
	if not self:move(self.collider.position + Vector2.new(self.velocity.x, 0) * dt) then
		self.velocity.x = 0
	end
	self:move(self.collider.position + Vector2.new(self.velocity.x, 0) * dt)
	self.velocity.y = self.velocity.y + 100 * dt
end

---@param collider Collider
function physicsBody.new(collider)
	local body = { collider = collider, velocity = Vector2.new(0, 0) }
	return setmetatable(body, bodyMetaData)
end

return physicsBody
