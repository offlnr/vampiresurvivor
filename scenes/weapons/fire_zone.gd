extends Node2D
## A burning patch: damages every enemy inside it at a fixed interval until it burns out.

const TICK := 0.4
const FALL_TIME := 0.25

var weapon: Weapon
var radius := 50.0
var _life := 0.0
var _tick_left := 0.0
var _time := 0.0

@onready var ground: Sprite2D = $Ground
@onready var flame: Sprite2D = $Flame


func ignite(owner_weapon: Weapon, pos: Vector2) -> void:
	weapon = owner_weapon
	position = pos
	radius = weapon.area()
	_life = weapon.stat(&"duration") + FALL_TIME
	_tick_left = FALL_TIME
	_time = 0.0
	ground.scale = Vector2.ONE * 0.01
	ground.modulate.a = 1.0
	flame.position = Vector2(0, -160)
	flame.modulate.a = 1.0
	flame.scale = Vector2.ONE * 1.4


func _physics_process(delta: float) -> void:
	_time += delta
	_life -= delta
	var full := radius * 2.0 / ground.texture.get_width()
	if _time < FALL_TIME:
		var t := _time / FALL_TIME
		flame.position = Vector2(0, lerpf(-160.0, -10.0, t * t))
	else:
		flame.position = Vector2(0, -10.0 + sin(_time * 10.0) * 2.0)
		ground.scale = Vector2.ONE * full * (1.0 + 0.04 * sin(_time * 7.0))
	if _life < 0.4:
		ground.modulate.a = maxf(_life / 0.4, 0.0)
		flame.modulate.a = ground.modulate.a
	if _life <= 0.0:
		weapon.release_zone(self)
		return
	_tick_left -= delta
	if _tick_left <= 0.0:
		_tick_left = TICK
		var hit_damage := weapon.damage()
		for enemy in weapon.enemies.in_radius(position, radius):
			weapon.enemies.damage(enemy, hit_damage, Vector2.ZERO, 0.0, EnemyManager.SOURCE_WEAPON, weapon.player)
