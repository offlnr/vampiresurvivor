extends Node2D
## A spinning bone that goes out, brakes, and returns to the player, hitting on the way.

const HIT_INTERVAL := 0.35
const MAX_LIFE := 5.0

var weapon: Weapon
var velocity := Vector2.ZERO
var radius := 18.0
var _out_time := 0.0
var _time := 0.0
var _returning := false
var _last_hit := {}

@onready var sprite: Sprite2D = $Sprite


func launch(owner_weapon: Weapon, pos: Vector2, direction: Vector2) -> void:
	weapon = owner_weapon
	position = pos
	velocity = direction * weapon.stat(&"speed")
	_out_time = weapon.stat(&"duration")
	_time = 0.0
	_returning = false
	_last_hit.clear()
	var size := weapon.area()
	radius = size * 0.5
	sprite.scale = Vector2.ONE * (size / sprite.texture.get_width())


func _physics_process(delta: float) -> void:
	_time += delta
	sprite.rotation += delta * 16.0
	var to_player := weapon.player.global_position - position
	if not _returning:
		# Brake towards zero speed by the end of the outward trip.
		velocity = velocity.move_toward(Vector2.ZERO, weapon.stat(&"speed") / _out_time * delta)
		var too_far := position.distance_to(weapon.player.global_position) >= weapon.data.attack_range
		if velocity.length() < 20.0 or too_far:
			_returning = true
	else:
		var speed := minf(velocity.length() + 900.0 * delta, weapon.stat(&"speed") * 1.3)
		velocity = to_player.normalized() * speed
		if to_player.length() < 24.0 or _time > MAX_LIFE:
			weapon.release_projectile(self)
			return
	position += velocity * delta
	var hit_damage := weapon.damage()
	for enemy in weapon.enemies.in_radius(position, radius):
		var key := enemy.get_instance_id()
		if _time - _last_hit.get(key, -INF) < HIT_INTERVAL:
			continue
		_last_hit[key] = _time
		weapon.enemies.damage(enemy, hit_damage, velocity, 120.0, EnemyManager.SOURCE_WEAPON, weapon.player)
