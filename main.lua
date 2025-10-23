Vector2 = require("libs.vectors")
Signal = require("libs.signal")
Flux = require("libs.flux")
Timer = require("libs.timer")
Console = require("libs.console")
Collision = require("libs.simpleCollision")
PhysicsBody = require("libs.physicsBody")
player = require("player")
game = require("game")

function love.load()
	game:start()
end

function love.keypressed(key)
	if key == "`" then
		Console:toggle()
		--Console:close()
	end
end

function love.mousepressed(x, y, button) end

function love.update(dt)
	game:update(dt)
end

function love.draw()
	game:draw()
	Console:draw()
end
