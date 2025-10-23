local editor = {}

local camera_position = Vector2.new(0, 0)
local camera_moving_speed = 150
local camera_scale = 1

local grid_size = 25
local grid_position = Vector2.new(0, 0)

local colliders = {}

function editor:update(dt)
	if love.keyboard.isDown("a") then
		camera_position.x = camera_position.x + camera_moving_speed * dt
	elseif love.keyboard.isDown("d") then
		camera_position.x = camera_position.x - camera_moving_speed * dt
	end
	if love.keyboard.isDown("w") then
		camera_position.y = camera_position.y + camera_moving_speed * dt
	elseif love.keyboard.isDown("s") then
		camera_position.y = camera_position.y - camera_moving_speed * dt
	end
end

local function drawGrid()
	love.graphics.push()
	love.graphics.setColor(1, 1, 1, 0.1)
	love.graphics.translate(-grid_size * 2, -grid_size * 2)
	love.graphics.translate(
		-math.floor(camera_position.x / grid_size) * grid_size,
		-math.floor(camera_position.y / grid_size) * grid_size
	)
	for x = 1, 33, 1 do
		for y = 1, 27, 1 do
			love.graphics.rectangle("line", x * grid_size, y * grid_size, grid_size, grid_size)
		end
	end
	love.graphics.pop()
end

function editor:draw()
	love.graphics.push()
	love.graphics.scale(camera_scale)
	--love.graphics.translate(camera_position.x / 2 * camera_scale, camera_position.y / 2 * camera_scale)
	love.graphics.translate(camera_position.x, camera_position.y)

	drawGrid()

	love.graphics.pop()
end

return editor
