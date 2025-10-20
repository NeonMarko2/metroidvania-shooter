local physicsBody = {}

---@class Body
---@field isGrounded boolean
---@field collider Collider
---@field velocity Vector
---@field onMoveFiltrationSettings table
local bodyMetaData = {}

---@private
bodyMetaData.__index = bodyMetaData

---move() will attempt to move the body to a spot if it is unoccupied
---@param newPosition Vector The position the body will attempt to move to.
---@return boolean wasSuccessful
function bodyMetaData:move(newPosition)
	local previousPosition = self.collider.position:copy()
	self.collider:move(newPosition)
	if self.collider:detectCollision(self.onMoveFiltrationSettings) then
		self.collider:move(previousPosition)
		return false
	end

	return true
end

---asign the body a new velocity
---@param newVelocity Vector
function bodyMetaData:throw(newVelocity)
	self.velocity = newVelocity
end

---@param dt number delta time
function bodyMetaData:update(dt)
	if not self:move(self.collider.position + Vector2.new(0, self.velocity.y) * dt) then
		if self.velocity.y > 0 then
			self.isGrounded = true
		end
		self.velocity.y = 0
	else
		self.isGrounded = false
	end
	if not self:move(self.collider.position + Vector2.new(self.velocity.x, 0) * dt) then
		self.velocity.x = 0
	end

	--self:move(self.collider.position + Vector2.new(self.velocity.x, 0) * dt)
	self.velocity.y = self.velocity.y + 2000 * dt
end

---@param collider Collider
function physicsBody.new(collider)
	local body = { collider = collider, velocity = Vector2.new(0, 0), isGrounded = false }
	return setmetatable(body, bodyMetaData)
end

return physicsBody
