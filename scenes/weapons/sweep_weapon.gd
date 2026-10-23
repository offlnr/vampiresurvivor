extends Weapon
## Scythe: a wide slash towards the nearest enemy; extra slashes are spread evenly around the player.

const SLASH_TEXTURE := preload("res://art/placeholder/slash.svg")
## Half of the arc covered by one slash.
const HALF_ARC := deg_to_rad(70.0)
## Looks for a target a bit beyond the blade's reach, so it swings as enemies approach.
const AIM_MARGIN := 60.0

var _slashes: Array[Sprite2D] = []


func _on_level_changed() -> void:
	while _slashes.size() < int(stat(&"amount")):
		var slash := Sprite2D.new()
		slash.texture = SLASH_TEXTURE
		slash.visible = false
		slash.z_index = 7
		add_child(slash)
		_slashes.append(slash)


func _attack() -> bool:
	var amount := int(stat(&"amount"))
	var radius := area()
	var hit_damage := damage()
	var targets := enemies.nearest(player.global_position, radius + AIM_MARGIN, 1)
	if targets.is_empty():
		return false
	var forward := player.global_position.direction_to(targets[0].position)
	for i in amount:
		var direction := forward.rotated(TAU * i / amount)
		for enemy in enemies.in_radius(player.global_position, radius):
			var to_enemy := enemy.position - player.global_position
			if absf(direction.angle_to(to_enemy)) <= HALF_ARC or to_enemy.length() < 26.0:
				enemies.damage(enemy, hit_damage, to_enemy, 220.0, EnemyManager.SOURCE_WEAPON, player)
		_show_slash(_slashes[i], direction, radius)
	Audio.play(&"slash", 0.1, -4.0)
	return true


func _show_slash(slash: Sprite2D, direction: Vector2, radius: float) -> void:
	var size := radius * 2.0 / SLASH_TEXTURE.get_width() * 1.1
	slash.visible = true
	slash.rotation = direction.angle() - deg_to_rad(10.0)
	slash.scale = Vector2.ONE * size * 0.7
	slash.modulate = Color(1, 1, 1, 1)
	var tween := create_tween()
	tween.tween_property(slash, "rotation", direction.angle() + deg_to_rad(25.0), 0.18).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(slash, "scale", Vector2.ONE * size, 0.18)
	tween.parallel().tween_property(slash, "modulate:a", 0.0, 0.25).set_delay(0.06)
	tween.tween_callback(func() -> void: slash.visible = false)
