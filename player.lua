local player = {}

player.position = Vector2.new(200, 300)
player.collider = Collision:addCollider(player.position, Vector2.new(50, 50), false)
player.body = PhysicsBody.new(player.collider)
player.weapon = require("rifle").new(player)

player.directionFacing = Vector2.new(0, 0)

function player:update(dt)
	if love.keyboard.isDown("d") then
		player.body:move(self.position + Vector2.new(180, 0) * dt)
		player.directionFacing = Vector2.new(1, 0)
	elseif love.keyboard.isDown("a") then
		player.body:move(self.position - Vector2.new(180, 0) * dt)
		player.directionFacing = Vector2.new(-1, 0)
	end
	if love.keyboard.isDown("space") and player.body.isGrounded then
		player.body:throw(Vector2.new(0, -600))
	end
	player.weapon:update(dt)
	player.body:update(dt)
	player.position = player.collider.position
end

function player:move(newPosition) end

function player:draw()
	love.graphics.rectangle("fill", self.position.x - 25, self.position.y - 25, 50, 50)
end

return player
