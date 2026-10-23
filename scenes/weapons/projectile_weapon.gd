extends Weapon
## Throws projectiles at the nearest enemies.

const SPREAD := 0.22

## What this weapon throws; the pumpkin by default.
@export var projectile_scene: PackedScene = preload("res://scenes/weapons/pumpkin_projectile.tscn")

var _pool: ObjectPool


func _on_setup() -> void:
	_pool = ObjectPool.new(projectile_scene.instantiate, projectiles_root)


func _attack() -> bool:
	var amount := int(stat(&"amount"))
	var targets := enemies.nearest(player.global_position, data.attack_range, amount)
	if targets.is_empty():
		return false
	for i in amount:
		var target: Enemy = targets[i % targets.size()]
		var direction := player.global_position.direction_to(target.position)
		if i >= targets.size():
			direction = direction.rotated(SPREAD * (1 if i % 2 == 0 else -1) * ceilf(i / 2.0))
		var projectile = _pool.acquire()
		projectile.launch(self, player.global_position, direction)
	Audio.play(&"throw", 0.1, -10.0)
	return true


func release_projectile(projectile: Node) -> void:
	_pool.release(projectile)
