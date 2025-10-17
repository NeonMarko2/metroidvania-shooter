local player = {}

player.position = Vector2.new(200, 300)
player.collider = Collision:addCollider(player.position, Vector2.new(50, 50), false)
player.body = PhysicsBody.new(player.collider)

function player:update(dt)
	if love.keyboard.isDown("d") then
		player.body:move(self.position + Vector2.new(180, 0) * dt)
	elseif love.keyboard.isDown("a") then
		player.body:move(self.position - Vector2.new(180, 0) * dt)
	end
	if love.keyboard.isDown("space") then
		player.body:throw(Vector2.new(0, -100))
	end
	player.body:update(dt)
	player.position = player.collider.position
end

function player:move(newPosition) end

function player:draw()
	love.graphics.rectangle("fill", self.position.x - 25, self.position.y - 25, 50, 50)
end

return player
