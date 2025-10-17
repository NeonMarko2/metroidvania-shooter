local rifle = {}

local function shootBullet(position, direction)
	local bullet = { collider = Collision:addCollider(position, Vector2.new(25, 25), false) }

	function bullet:update(dt)
		bullet.collider.position = bullet.collider.position + direction * 500 * dt
	end
	AddToUpdate(bullet)

	Timer:after(5, function()
		RemoveFromUpdate(bullet)
		Collision:removeCollider(bullet.collider)
	end)
end

function rifle.new(player)
	local weapon = {}

	function weapon:update(dt)
		if love.keyboard.isDown("j") then
			shootBullet(player.position:copy(), player.directionFacing)
		end
	end

	return weapon
end

return rifle
