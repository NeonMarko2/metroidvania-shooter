local enemy = {}

function enemy.new(position)
	local tempEnemy = {}
	tempEnemy.position = position:copy()
	tempEnemy.collider = Collision:addCollider(tempEnemy.position, Vector2.new(50, 50), tempEnemy, "enemy")
	tempEnemy.body = PhysicsBody.new(tempEnemy.collider)

	function tempEnemy.damage(damageAmount)
		Collision:removeCollider(tempEnemy.collider)
		RemoveFromUpdate(tempEnemy)
		tempEnemy = nil
	end

	AddToUpdate(tempEnemy)

	function tempEnemy:update(dt)
		tempEnemy.body:update(dt)
	end
end

return enemy
