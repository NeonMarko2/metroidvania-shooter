Vector2 = require("libs.vectors")
Signal = require("libs.signal")
Flux = require("libs.flux")
Timer = require("libs.timer")
Console = require("libs.console")
Collision = require("libs.simpleCollision")
PhysicsBody = require("libs.physicsBody")
player = require("player")
game = require("game")
local level_editor = require("editor")

local current_mode = game

function love.load()
	game:start()
end

function love.keypressed(key)
	if key == "`" then
		Console:toggle()
		--Console:close()
	elseif key == "e" then
		if current_mode == game then
			current_mode = level_editor
		else
			current_mode = game
		end
	end
end

function love.mousepressed(x, y, button) end

function love.update(dt)
	current_mode:update(dt)
end

function love.draw()
	current_mode:draw()
	Console:draw()
end
