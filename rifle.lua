local rifle = {}

local function shootBullet(position, direction)
	local bullet = { collider = Collision:addCollider(position, Vector2.new(25, 25)) }

	function bullet:update(dt)
		bullet.collider:move(bullet.collider.position + direction * 500 * dt)
		local didCollide, supers = bullet.collider:detectCollision({ mode = "blacklist", layers = { "player" } })
		if didCollide then
			for _, super in pairs(supers) do
				if super ~= nil and super.damage ~= nil then
					super.damage(1)
				end
			end

			RemoveFromUpdate(bullet)
			Collision:removeCollider(bullet.collider)
			bullet = nil
		end
	end
	AddToUpdate(bullet)

	Timer:after(5, function()
		if not bullet then
			return
		end
		RemoveFromUpdate(bullet)
		Collision:removeCollider(bullet.collider)
		bullet = nil
	end)
end

function rifle.new(player)
	local weapon = { canShoot = true }

	function weapon:update(dt)
		if love.keyboard.isDown("j") and weapon.canShoot then
			shootBullet(player.position:copy(), player.directionFacing)
			weapon.canShoot = false
			Timer:after(0.15, function()
				weapon.canShoot = true
			end)
		end
	end

	return weapon
end

return rifle
