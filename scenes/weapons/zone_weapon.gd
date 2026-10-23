extends Weapon
## Will-o'-wisp: green flames fall on random enemies on screen and leave a burning zone.

const ZONE_SCENE := preload("res://scenes/weapons/fire_zone.tscn")

var _pool: ObjectPool


func _on_setup() -> void:
	_pool = ObjectPool.new(ZONE_SCENE.instantiate, projectiles_root)


func _attack() -> bool:
	var targets := enemies.nearest(player.global_position, data.attack_range, 40)
	targets.shuffle()
	if targets.is_empty():
		return false
	for i in mini(int(stat(&"amount")), targets.size()):
		_pool.acquire().ignite(self, targets[i].position)
	Audio.play(&"fire", 0.15, -6.0)
	return true


func release_zone(zone: Node) -> void:
	_pool.release(zone)
