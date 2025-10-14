local player = {}

player.position = Vector2.new(200, 200)

function player:update(dt)
	if love.keyboard.isDown("d") then
		self.position.x = self.position.x + 25 * dt
	elseif love.keyboard.isDown("a") then
		self.position.x = self.position.x - 25 * dt
	end
end

function player:draw()
	love.graphics.rectangle("fill", self.position.x, self.position.y, 50, 50)
end

return player
