Vector2 = require("libs.vectors")
Signal = require("libs.signal")
Flux = require("libs.flux")
Timer = require("libs.timer")
Console = require("libs.console")
local player = require("player")

function love.load() end

function love.keypressed(key)
	if key == "`" then
		Console:toggle()
		--Console:close()
	end
end

function love.update(dt)
	player:update(dt)
end

function love.draw()
	love.graphics.setBackgroundColor(0.4, 0.2, 0.3, 1)
	Console:draw()
	player:draw()
end
