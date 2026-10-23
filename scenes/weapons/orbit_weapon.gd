extends Weapon
## Bats that circle the player for `duration` seconds, then rest for `cooldown`.

const BAT_TEXTURE := preload("res://art/placeholder/bat_ally.svg")
const BAT_SIZE := 46.0
const HIT_RADIUS := 20.0
const HIT_INTERVAL := 0.5
const ORBIT_SPEED := 3.4

var _bats: Array[Sprite2D] = []
var _angle := 0.0
var _active_left := 0.0
var _time := 0.0
var _last_hit := {}


func _on_level_changed() -> void:
	var amount := int(stat(&"amount"))
	while _bats.size() < amount:
		var bat := Sprite2D.new()
		bat.texture = BAT_TEXTURE
		bat.z_index = 6
		bat.visible = _active_left > 0.0
		add_child(bat)
		_bats.append(bat)


func _physics_process(delta: float) -> void:
	if player == null or player.is_dead:
		return
	_time += delta
	if _active_left > 0.0:
		_active_left -= delta
		_angle += ORBIT_SPEED * delta
		_layout()
		_hit_enemies()
		if _active_left <= 0.0:
			_set_bats_visible(false)
			_cooldown_left = cooldown()
	else:
		_cooldown_left -= delta
		if _cooldown_left <= 0.0:
			_active_left = stat(&"duration")
			_set_bats_visible(true)
			_layout()
			Audio.play(&"bats", 0.1, -8.0)


func _layout() -> void:
	var radius := area()
	var base_scale := BAT_SIZE / BAT_TEXTURE.get_width()
	for i in _bats.size():
		var bat := _bats[i]
		var angle := _angle + TAU * i / _bats.size()
		bat.position = Vector2.from_angle(angle) * radius
		bat.flip_h = cos(angle) > 0.0
		bat.scale = Vector2(base_scale, base_scale * (0.75 + 0.25 * absf(sin(_time * 18.0 + i))))


func _hit_enemies() -> void:
	var hit_damage := damage()
	for bat in _bats:
		var pos := global_position + bat.position
		for enemy in enemies.in_radius(pos, HIT_RADIUS):
			var key := enemy.get_instance_id()
			if _time - _last_hit.get(key, -INF) < HIT_INTERVAL:
				continue
			_last_hit[key] = _time
			enemies.damage(enemy, hit_damage, enemy.position - player.global_position, 180.0)
	if _last_hit.size() > 500:
		_last_hit.clear()


func _set_bats_visible(value: bool) -> void:
	for bat in _bats:
		bat.visible = value
		if value:
			bat.modulate.a = 0.0
			create_tween().tween_property(bat, "modulate:a", 1.0, 0.15)
