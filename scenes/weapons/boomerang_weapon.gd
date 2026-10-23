extends Weapon
## Bone boomerang: flies towards the nearest enemy, slows down and comes back.

const BONE_SCENE := preload("res://scenes/weapons/bone_projectile.tscn")

var _pool: ObjectPool


func _on_setup() -> void:
	_pool = ObjectPool.new(BONE_SCENE.instantiate, projectiles_root)


func _attack() -> bool:
	var amount := int(stat(&"amount"))
	var targets := enemies.nearest(player.global_position, data.attack_range, 1)
	if targets.is_empty():
		return false
	var direction := player.global_position.direction_to(targets[0].position)
	for i in amount:
		var spread := (i - (amount - 1) / 2.0) * 0.45
		_pool.acquire().launch(self, player.global_position, direction.rotated(spread))
	Audio.play(&"throw", 0.15, -8.0)
	return true


func release_projectile(projectile: Node) -> void:
	_pool.release(projectile)
