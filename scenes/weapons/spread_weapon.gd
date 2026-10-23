extends Weapon
## Silver blunderbuss (Megabonk's shotgun): a fan of short-range pellets towards the nearest enemy.
## Each extra projectile is one more pellet in the fan.

const PELLET_SCENE := preload("res://scenes/weapons/silver_pellet.tscn")
## Angle between two pellets, and the widest the fan can open.
const PELLET_GAP := 0.13
const MAX_FAN := 1.3

var _pool: ObjectPool


func _on_setup() -> void:
	_pool = ObjectPool.new(PELLET_SCENE.instantiate, projectiles_root)


func _attack() -> bool:
	var targets := enemies.nearest(player.global_position, data.attack_range, 1)
	if targets.is_empty():
		return false
	var amount := int(stat(&"amount"))
	var forward := player.global_position.direction_to(targets[0].position)
	var gap := minf(PELLET_GAP, MAX_FAN / maxf(amount - 1, 1))
	for i in amount:
		var direction := forward.rotated((i - (amount - 1) / 2.0) * gap + randf_range(-0.03, 0.03))
		_pool.acquire().launch(self, player.global_position, direction)
	Audio.play(&"blunderbuss", 0.1, -7.0)
	return true


func release_projectile(projectile: Node) -> void:
	_pool.release(projectile)
