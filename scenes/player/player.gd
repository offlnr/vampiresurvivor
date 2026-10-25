class_name Player
extends CharacterBody2D
## The player character: movement, health, contact damage and passive stats.

signal health_changed(current: float, maximum: float)
signal died

const VISUAL_HEIGHT := 68.0
const BODY_RADIUS := 16.0
const BASE_SPEED := 210.0
const BASE_MAX_HEALTH := 100.0
const BASE_PICKUP_RADIUS := 110.0
const INVULNERABLE_TIME := 0.7
const RAGE_ATTACK_SPEED := 0.6
## Lifesteal heals at most this share of max health per second, however many enemies are hit.
const LIFESTEAL_CAP_PER_SECOND := 0.02
## Seconds without being hit before the shield starts to recharge, and share of it recharged per second.
const SHIELD_DELAY := 4.0
const SHIELD_RECHARGE := 0.25
## Invulnerability after dodging a hit, so contact damage doesn't roll again every frame.
const DODGE_INVULNERABLE := 0.35
## Thorns hit the enemies touching the player within this reach.
const THORNS_REACH := 28.0
## Invulnerability after being revived (rewarded ad).
const REVIVE_INVULNERABLE := 3.0
## The camera always shows at least this many world units on the short side of the screen.
const MIN_VISIBLE_WORLD := 720.0
const SHIELD_COLOR := Color("6cc8ff")

var enemies: EnemyManager
var inventory: Inventory
var decorations: Decorations
## Active power-up effects: name -> seconds left.
var buffs := {}
var max_health := BASE_MAX_HEALTH
var health := BASE_MAX_HEALTH
var speed_multiplier := 1.0
var pickup_multiplier := 1.0
## Extra attacks per second, as a fraction; cooldowns are divided by (1 + this), so it has no cap.
var attack_speed_bonus := 0.0
var damage_multiplier := 1.0
var area_multiplier := 1.0
var luck := 0.0
var lifesteal := 0.0
## Each armor level multiplies the damage taken by (1 - x), so it never reaches immunity.
var damage_taken_multiplier := 1.0
var xp_multiplier := 1.0
## Extra projectiles (bats, slashes, flames...) added to every weapon. Always whole.
var extra_amount := 0
## Health recovered per second.
var regen := 0.0
## Shield points: absorb damage before health, and recharge after a while without being hit.
var shield_max := 0.0
var shield := 0.0
## Evasion stat; the chance to dodge a hit is evasion / (1 + evasion), so it never reaches 100 %.
var evasion := 0.0
## Damage dealt back to the enemies touching the player when it is hit (scaled by the damage multiplier).
var thorns := 0.0
## Critical hit chance from scrolls, on top of items. Critical hits deal double damage.
var crit_chance := 0.0
var projectile_speed_multiplier := 1.0
var duration_multiplier := 1.0
var knockback_multiplier := 1.0
## Silver earned at the end of the run (unlocks between runs).
var silver_multiplier := 1.0
## Extra gold, as a fraction (cauldrons), on top of items.
var gold_bonus := 0.0
var is_dead := false
var last_move_direction := Vector2.RIGHT
## Online co-op: the guest's character moves with the direction the guest sends (see NetHost)
## instead of this device's controls.
var remote_input := false
var remote_direction := Vector2.ZERO

var _invulnerable_left := 0.0
var _since_hit := 0.0
var _death_tween: Tween
var _shake_left := 0.0
## Health lifesteal can still heal; refills up to one second of the cap.
var _lifesteal_budget := 0.0

@onready var visual: Node2D = $Visual
@onready var sprite: AnimatedSprite2D = $Visual/Sprite
@onready var weapons: Node2D = $Weapons
@onready var camera: Camera2D = $Camera


func _ready() -> void:
	var frame := sprite.sprite_frames.get_frame_texture(&"idle", 0)
	sprite.scale = Vector2.ONE * (VISUAL_HEIGHT / frame.get_height())
	sprite.play(&"idle")
	get_viewport().size_changed.connect(_update_zoom)
	_update_zoom()


## The character's look (see CharacterData), scaled to the same height as every other.
func set_frames(frames: SpriteFrames) -> void:
	sprite.sprite_frames = frames
	var frame := frames.get_frame_texture(&"idle", 0)
	sprite.scale = Vector2.ONE * (VISUAL_HEIGHT / frame.get_height())
	sprite.play(&"idle")


func move_speed() -> float:
	var bonus := inventory.move_speed_bonus() if inventory != null else 0.0
	var broom := 1.4 if has_buff(&"broom") else 1.0
	return BASE_SPEED * (speed_multiplier + bonus) * broom


func add_buff(buff: StringName, seconds: float) -> void:
	buffs[buff] = maxf(buffs.get(buff, 0.0), seconds)


func has_buff(buff: StringName) -> bool:
	return buffs.get(buff, 0.0) > 0.0


## Damage multiplier from items, on top of `damage_multiplier`.
func item_damage_multiplier() -> float:
	return inventory.damage_multiplier() if inventory != null else 1.0


## Total attack speed from scrolls, items and the rage power-up.
func attack_speed() -> float:
	var items := inventory.attack_speed_bonus() if inventory != null else 0.0
	return attack_speed_bonus + items + (RAGE_ATTACK_SPEED if has_buff(&"rage") else 0.0)


func add_armor(fraction: float) -> void:
	damage_taken_multiplier *= 1.0 - fraction


func gold_multiplier() -> float:
	var bonus := gold_bonus + (inventory.gold_bonus() if inventory != null else 0.0)
	return (1.0 + bonus) * (2.0 if has_buff(&"gold_rain") else 1.0)


## Seconds since the player last lost health or shield.
func time_since_hit() -> float:
	return _since_hit


## Chance to dodge a hit, with diminishing returns.
func dodge_chance() -> float:
	return evasion / (1.0 + evasion)


func add_shield(amount: float) -> void:
	shield_max += amount
	shield += amount
	queue_redraw()


func pickup_radius() -> float:
	return BASE_PICKUP_RADIUS * pickup_multiplier


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	var direction := remote_direction.limit_length(1.0) if remote_input else Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	velocity = direction * move_speed()
	move_and_slide()
	if decorations != null:
		# Crypts, trees and other solid props: slide around them.
		global_position = decorations.push_out(global_position, BODY_RADIUS)
	if direction != Vector2.ZERO:
		last_move_direction = direction.normalized()
	_animate(direction)

	for buff: StringName in buffs.keys():
		buffs[buff] -= delta
		if buffs[buff] <= 0.0:
			buffs.erase(buff)
	_invulnerable_left = maxf(_invulnerable_left - delta, 0.0)
	_since_hit += delta
	if regen > 0.0 and health < max_health:
		heal(regen * delta)
	if shield < shield_max and _since_hit >= SHIELD_DELAY:
		shield = minf(shield + shield_max * SHIELD_RECHARGE * delta, shield_max)
		queue_redraw()
	var lifesteal_cap := max_health * LIFESTEAL_CAP_PER_SECOND
	_lifesteal_budget = minf(_lifesteal_budget + lifesteal_cap * delta, lifesteal_cap)
	if _invulnerable_left <= 0.0 and enemies != null:
		var damage := enemies.contact_damage_at(global_position, BODY_RADIUS)
		if damage > 0.0:
			take_damage(damage)
	var blinking := _invulnerable_left > 0.0 and fmod(_invulnerable_left, 0.12) < 0.06
	visual.modulate.a = 0.3 if blinking else 1.0
	visual.self_modulate = Color(0.75, 1.0, 0.7) if has_buff(&"shield") else Color.WHITE


func _process(delta: float) -> void:
	if _shake_left > 0.0:
		_shake_left -= delta
		camera.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * 6.0 * (_shake_left / 0.2)
	else:
		camera.offset = Vector2.ZERO


func take_damage(amount: float) -> void:
	if is_dead or _invulnerable_left > 0.0 or has_buff(&"shield"):
		return
	if evasion > 0.0 and randf() < dodge_chance():
		_invulnerable_left = DODGE_INVULNERABLE
		if inventory != null:
			inventory.on_player_dodged()
		return
	_since_hit = 0.0
	_hit_back()
	var taken := maxf(amount * damage_taken_multiplier, 1.0)
	if shield > 0.0:
		var absorbed := minf(shield, taken)
		shield -= absorbed
		taken -= absorbed
		if taken <= 0.0:
			_invulnerable_left = INVULNERABLE_TIME
			Audio.play(&"hit", 0.05)
			queue_redraw()
			return
	if taken >= health and inventory != null and inventory.try_last_stand():
		# Stopped hourglass: the lethal hit never lands and time stops around the player.
		_invulnerable_left = Inventory.LAST_STAND_TIME
		return
	health = maxf(health - taken, 0.0)
	_invulnerable_left = INVULNERABLE_TIME
	_shake_left = 0.2
	Audio.play(&"hurt", 0.05)
	_emit_health()
	Events.player_damaged.emit(health, max_health)
	if health <= 0.0:
		_die()
	elif inventory != null:
		inventory.on_player_hurt(taken)


## Thorns: the enemies touching the player take damage back.
func _hit_back() -> void:
	if thorns <= 0.0 or enemies == null:
		return
	var hit_damage := thorns * damage_multiplier
	for enemy in enemies.in_radius(global_position, BODY_RADIUS + THORNS_REACH):
		enemies.damage(enemy, hit_damage, enemy.position - global_position, 160.0, EnemyManager.SOURCE_ITEM, self)


## Called for every hit the player's weapons land, with the damage the enemy had health for.
func on_damage_dealt(amount: float) -> void:
	if lifesteal <= 0.0 or is_dead or health >= max_health or _lifesteal_budget <= 0.0:
		return
	var healed := minf(amount * lifesteal, _lifesteal_budget)
	_lifesteal_budget -= healed
	heal(healed)


func heal(amount: float) -> void:
	health = minf(health + amount, max_health)
	_emit_health()


func increase_max_health(amount: float) -> void:
	max_health += amount
	health += amount
	_emit_health()


func _die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	visual.modulate.a = 1.0
	sprite.play(&"idle")
	sprite.pause()
	_death_tween = create_tween()
	_death_tween.tween_property(visual, "rotation", PI / 2.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_death_tween.parallel().tween_property(visual, "modulate", Color(0.6, 0.5, 0.8, 0.8), 0.4)
	died.emit()
	Events.player_died.emit()


## Second chance: back on its feet with a share of its health, full shield and a moment of invulnerability.
func revive(health_fraction: float) -> void:
	if _death_tween != null:
		_death_tween.kill()
	is_dead = false
	health = max_health * health_fraction
	shield = shield_max
	_invulnerable_left = REVIVE_INVULNERABLE
	_since_hit = 0.0
	visual.rotation = 0.0
	visual.modulate = Color.WHITE
	sprite.play(&"idle")
	_emit_health()


func _emit_health() -> void:
	health_changed.emit(health, max_health)
	queue_redraw()


func _animate(direction: Vector2) -> void:
	if direction.x != 0.0:
		sprite.flip_h = direction.x < 0.0
	var animation := &"walk" if direction != Vector2.ZERO else &"idle"
	if sprite.animation != animation:
		sprite.play(animation)
	# Faster legs when the player has more speed.
	sprite.speed_scale = speed_multiplier if animation == &"walk" else 1.0


func _update_zoom() -> void:
	var size := get_viewport_rect().size
	camera.zoom = Vector2.ONE * maxf(minf(size.x, size.y) / MIN_VISIBLE_WORLD, 0.5)


func _draw() -> void:
	NetDraw.paint(self, draw_ops())


## Small health bar under the character, as in the genre (see NetDraw).
func draw_ops() -> Array:
	var width := 44.0
	var origin := Vector2(-width / 2.0, VISUAL_HEIGHT / 2.0 + 8.0)
	var ops: Array = [
		[NetDraw.RECT, Rect2(origin - Vector2(2, 2), Vector2(width + 4, 9)), Palette.INK],
		[NetDraw.RECT, Rect2(origin, Vector2(width * health / max_health, 5)), Palette.RED],
	]
	if shield_max > 0.0:
		var top := origin + Vector2(0, 9)
		ops.append([NetDraw.RECT, Rect2(top - Vector2(2, 2), Vector2(width + 4, 7)), Palette.INK])
		ops.append([NetDraw.RECT, Rect2(top, Vector2(width * shield / shield_max, 3)), SHIELD_COLOR])
	return ops
