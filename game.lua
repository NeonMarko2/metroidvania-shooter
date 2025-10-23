local game = {}

function game:start()
	Collision:addCollider(Vector2.new(100, 300), Vector2.new(100, 100), false)
	Collision:addCollider(Vector2.new(400, 550), Vector2.new(600, 25), true)
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

function game:update(dt)
	player:update(dt)
	runObjectUpdates(dt)
	Collision:update()
end

function game:draw()
	love.graphics.setBackgroundColor(0.4, 0.2, 0.3, 1)
	player:draw()
	Collision:drawColliders_Debug()
end

return game
