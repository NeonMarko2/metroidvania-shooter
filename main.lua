Vector2 = require("libs.vectors")
Signal = require("libs.signal")
Flux = require("libs.flux")
Timer = require("libs.timer")
Console = require("libs.console")
Collision = require("libs.simpleCollision")
PhysicsBody = require("libs.physicsBody")
local player = require("player")
local enemy = require("enemy")

function love.load()
	Collision:addCollider(Vector2.new(100, 300), Vector2.new(100, 100), false, "ground")
	Collision:addCollider(Vector2.new(400, 550), Vector2.new(600, 25), true, "ground")
	enemy.new(Vector2.new(600, 300))
end

function love.keypressed(key)
	if key == "`" then
		Console:toggle()
		--Console:close()
	end
end

local objects = {}

function AddToUpdate(object)
	objects[object] = object
end

function RemoveFromUpdate(object)
	objects[object] = nil
end

function love.mousepressed(x, y, button) end

local function runObjectUpdates(dt)
	for _, object in pairs(objects) do
		object:update(dt)
	end
end

function love.update(dt)
	player:update(dt)
	runObjectUpdates(dt)
	Timer:update(dt)
	local mouseX, mouseY = love.mouse.getPosition()
	Collision:update()
end

function love.draw()
	love.graphics.setBackgroundColor(0.4, 0.2, 0.3, 1)
	player:draw()
	Collision:drawColliders_Debug()
	Console:draw()
end
