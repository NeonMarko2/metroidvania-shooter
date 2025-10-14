local player = {}

player.position = Vector2.new(200, 200)

function player:update(dt) end

function player:draw()
	love.graphics.rectangle("fill", self.position.x, self.position.y, 50, 50)
end

return player
