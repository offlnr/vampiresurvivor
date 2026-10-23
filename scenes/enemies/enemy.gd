class_name Enemy
extends Node2D
## One pooled enemy. Movement and damage are driven by EnemyManager.

const FLASH_TIME := 0.08
const SPAWN_TIME := 0.45
const ELITE_SCALE := 2.0
const ELITE_HEALTH := 12.0
const ELITE_DAMAGE := 2.0
const ELITE_SPEED := 0.85
const ELITE_XP := 10

var data: EnemyData
var health := 1.0
var max_health := 1.0
var radius := 16.0
var speed := 80.0
var contact_damage := 5.0
var xp_value := 1
var knockback := Vector2.ZERO
var alive := false
var is_elite := false
## Horde enemies don't count towards the normal wave limit.
var is_horde := false
## Swarm enemies fly in a straight line instead of chasing, until `life_left` runs out.
var fixed_velocity := Vector2.ZERO
var life_left := 0.0
var spawn_left := 0.0
## Damage over time from poison items.
var poison_left := 0.0
var poison_dps := 0.0
var poison_tick := 0.0
var frozen_left := 0.0
## Multiplies contact, explosion and potion damage (endless scaling).
var damage_multiplier := 1.0
var attack_left := 0.0

var _flash_left := 0.0
var _time := 0.0
var _base_scale := 1.0
var _height := 56.0
var _animation_speed := 1.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var outline: AnimatedSprite2D = $Outline
@onready var shadow: Sprite2D = $Shadow


func setup(enemy_data: EnemyData, health_multiplier: float, elite := false, speed_multiplier := 1.0, damage_scale := 1.0) -> void:
	data = enemy_data
	is_elite = elite
	is_horde = false
	fixed_velocity = Vector2.ZERO
	life_left = 0.0
	var size := ELITE_SCALE if elite else 1.0
	max_health = enemy_data.max_health * health_multiplier * (ELITE_HEALTH if elite else 1.0)
	health = max_health
	radius = enemy_data.radius * size
	speed = enemy_data.speed * speed_multiplier * randf_range(0.9, 1.1) * (ELITE_SPEED if elite else 1.0)
	damage_multiplier = damage_scale
	contact_damage = enemy_data.contact_damage * damage_scale * (ELITE_DAMAGE if elite else 1.0)
	attack_left = enemy_data.attack_cooldown * randf_range(0.5, 1.0)
	xp_value = enemy_data.xp_value * (ELITE_XP if elite else 1)
	knockback = Vector2.ZERO
	alive = true
	spawn_left = SPAWN_TIME
	poison_left = 0.0
	poison_dps = 0.0
	frozen_left = 0.0
	_flash_left = 0.0
	_time = randf() * TAU
	_height = enemy_data.visual_height * size

	sprite.sprite_frames = enemy_data.frames
	sprite.play(&"move")
	sprite.frame = randi() % enemy_data.frames.get_frame_count(&"move")
	_animation_speed = randf_range(0.85, 1.15)
	sprite.speed_scale = _animation_speed
	_base_scale = _height / enemy_data.frame_texture().get_height()
	sprite.modulate = enemy_data.tint
	sprite.self_modulate = Color.WHITE
	sprite.position = Vector2.ZERO
	outline.visible = elite
	if elite:
		outline.sprite_frames = enemy_data.frames
		outline.animation = &"move"
	shadow.position.y = _height * 0.45
	shadow.scale = Vector2.ONE * (radius * 2.6 / 64.0)
	_apply_spawn_visual()
	queue_redraw()


func is_spawning() -> bool:
	return spawn_left > 0.0


func poison(dps: float, duration: float) -> void:
	poison_dps = maxf(poison_dps if poison_left > 0.0 else 0.0, dps)
	poison_left = maxf(poison_left, duration)
	if poison_tick <= 0.0:
		poison_tick = 0.5


func freeze(duration: float) -> void:
	frozen_left = maxf(frozen_left, duration)


func flash() -> void:
	_flash_left = FLASH_TIME
	sprite.self_modulate = Color(5, 5, 5)
	if is_elite:
		queue_redraw()


## Texture currently shown, for the death effect.
func current_texture() -> Texture2D:
	return sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)


func visual_scale() -> float:
	return _base_scale


func animate(delta: float, direction_x: float, stopped := false) -> void:
	_apply_status_tint(stopped)
	if stopped:
		return
	sprite.speed_scale = _animation_speed
	_time += delta
	if spawn_left > 0.0:
		spawn_left = maxf(spawn_left - delta, 0.0)
		_apply_spawn_visual()
	elif data.floaty:
		sprite.position.y = sin(_time * 3.0) * 6.0 - 4.0
		sprite.modulate.a = data.tint.a * (0.8 + 0.15 * sin(_time * 2.0))
	if absf(direction_x) > 0.1:
		sprite.flip_h = direction_x < 0.0
	if is_elite:
		outline.frame = sprite.frame
		outline.flip_h = sprite.flip_h
		outline.position = sprite.position
		outline.scale = sprite.scale * 1.12
		outline.modulate.a = 0.75 + 0.25 * sin(_time * 6.0)
	if _flash_left > 0.0:
		_flash_left -= delta
		if _flash_left <= 0.0:
			sprite.self_modulate = Color.WHITE


## Frozen or time-stopped enemies turn icy blue and stop animating; poisoned ones turn green.
func _apply_status_tint(stopped: bool) -> void:
	var tint := data.tint
	if stopped:
		tint = Color(0.62, 0.8, 1.0, tint.a)
		sprite.speed_scale = 0.0
	elif poison_left > 0.0:
		tint = Color(0.62, 1.0, 0.55, tint.a)
	sprite.modulate = Color(tint.r, tint.g, tint.b, sprite.modulate.a)


func _apply_spawn_visual() -> void:
	var progress := 1.0 - spawn_left / SPAWN_TIME
	var eased := ease(progress, -2.0)
	sprite.scale = Vector2.ONE * _base_scale
	sprite.modulate.a = data.tint.a * eased
	match data.spawn_style:
		EnemyData.SpawnStyle.RISE:
			# Climbs out of the ground: grows from the feet up.
			sprite.scale.y = _base_scale * maxf(eased, 0.05)
			sprite.position.y = (1.0 - eased) * _height * 0.5
		EnemyData.SpawnStyle.FADE:
			sprite.scale = Vector2.ONE * _base_scale * (0.6 + 0.4 * eased)
		EnemyData.SpawnStyle.DROP:
			sprite.position.y = -(1.0 - eased) * 90.0
	shadow.modulate.a = eased


func _draw() -> void:
	NetDraw.paint(self, draw_ops())


## Elites show a health bar over their head (see NetDraw).
func draw_ops() -> Array:
	if not is_elite or not alive:
		return []
	var width := 70.0
	var origin := Vector2(-width / 2.0, -_height * 0.6 - 14.0)
	return [
		[NetDraw.RECT, Rect2(origin - Vector2(2, 2), Vector2(width + 4, 10)), Palette.INK],
		[NetDraw.RECT, Rect2(origin, Vector2(width * maxf(health, 0.0) / max_health, 6)), Palette.GOLD],
	]
