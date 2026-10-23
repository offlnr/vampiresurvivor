class_name PickupManager
extends Node2D
## Souls on the ground: attraction towards the player, collection and merging.

## `collector` is the character that picked it up (experience is shared, gold and chests are its own).
signal collected(xp: int, collector: Player)
signal chest_opened(collector: Player)
signal gold_collected(amount: int, collector: Player)
signal power_up_collected(kind: StringName)

const CHEST_TEXTURE := preload("res://art/placeholder/chest.svg")
const CHEST_REACH := 34.0
const POWER_UP_REACH := 38.0
const POWER_UP_LIFE := 30.0
const MAX_POWER_UPS := 12
const SOUL_HIT_RADIUS := 16.0
const SOUL_HIT_INTERVAL := 0.3

const SOUL_SCENE := preload("res://scenes/pickups/soul_gem.tscn")
## Above this many souls on the ground, new ones are added to the nearest existing soul.
const MERGE_THRESHOLD := 300
const COLLECT_DISTANCE := 20.0
const POP_SPEED := -160.0
const ACCELERATION := 1700.0
const MAX_FLY_SPEED := 950.0

var player: Player
## Every character that collects: the player, plus the guest's in online co-op. Empty means just `player`.
## Experience and gold are shared, so whoever is nearest takes each soul or coin.
var players: Array[Player] = []
var enemies: EnemyManager
var decorations: Decorations
var inventory: Inventory

var _pool: ObjectPool
var _coins: ObjectPool
var _power_ups: Array[Sprite2D] = []
var _chests: Array[Sprite2D] = []
var _time := 0.0


func _ready() -> void:
	_pool = ObjectPool.new(SOUL_SCENE.instantiate, self)
	_coins = ObjectPool.new(Coin.new, self)


func count() -> int:
	return _pool.active.size()


func pool_size() -> int:
	return _pool.size()


func spawn_chest(pos: Vector2) -> void:
	var chest := Sprite2D.new()
	chest.texture = CHEST_TEXTURE
	chest.position = _reachable(pos)
	chest.z_index = 2
	add_child(chest)
	_chests.append(chest)
	chest.scale = Vector2.ZERO
	chest.create_tween().tween_property(chest, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Chests and power-ups dropped over a crypt (by a flying enemy) are moved to where the player can reach them.
func _reachable(pos: Vector2) -> Vector2:
	return decorations.push_out(pos, 20.0) if decorations != null else pos


func chest_count() -> int:
	return _chests.size()


func chest_positions() -> Array[Vector2]:
	var result: Array[Vector2] = []
	for chest in _chests:
		result.append(chest.position)
	return result


func coin_count() -> int:
	return _coins.active.size()


func spawn_coins(pos: Vector2, amount: int) -> void:
	for i in amount:
		var coin: Coin = _coins.acquire()
		coin.setup()
		coin.position = pos + Vector2(randf_range(-18, 18), randf_range(-18, 18)) * (1.0 if amount > 1 else 0.3)


func spawn_power_up(pos: Vector2, kind: StringName) -> void:
	if _power_ups.size() >= MAX_POWER_UPS:
		return
	var power_up := Sprite2D.new()
	power_up.texture = PowerUps.icon(kind)
	power_up.position = _reachable(pos)
	power_up.z_index = 3
	power_up.set_meta(&"kind", kind)
	power_up.set_meta(&"life", POWER_UP_LIFE)
	var glow := Sprite2D.new()
	glow.texture = preload("res://art/placeholder/puff.svg")
	glow.modulate = Color(Palette.GOLD, 0.45)
	glow.scale = Vector2.ONE * 1.3
	glow.show_behind_parent = true
	power_up.add_child(glow)
	add_child(power_up)
	_power_ups.append(power_up)
	power_up.scale = Vector2.ZERO
	power_up.create_tween().tween_property(power_up, "scale", Vector2.ONE * 0.75, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func power_up_positions() -> Array[Vector2]:
	var result: Array[Vector2] = []
	for power_up in _power_ups:
		result.append(power_up.position)
	return result


func spawn_soul(pos: Vector2, value: int) -> void:
	if _pool.active.size() >= MERGE_THRESHOLD:
		var nearest: SoulGem = null
		var best := INF
		for soul: SoulGem in _pool.active:
			var distance := soul.position.distance_squared_to(pos)
			if distance < best and not soul.attracted:
				best = distance
				nearest = soul
		if nearest != null:
			nearest.set_value(nearest.value + value)
			return
	var soul: SoulGem = _pool.acquire()
	soul.setup(value)
	soul.position = pos + Vector2(randf_range(-6, 6), randf_range(-6, 6))


## Pulls every soul and coin on the ground towards the player.
func attract_all() -> void:
	for soul: SoulGem in _pool.active:
		if not soul.attracted:
			soul.attracted = true
			soul.fly_speed = POP_SPEED
	for coin: Coin in _coins.active:
		if not coin.attracted:
			coin.attracted = true
			coin.fly_speed = POP_SPEED


## The living character nearest to `pos`, or null when everyone is dead.
func _nearest_player(pos: Vector2) -> Player:
	var best: Player = null
	var best_distance := INF
	for p in players if not players.is_empty() else [player]:
		var distance := p.global_position.distance_squared_to(pos)
		if not p.is_dead and distance < best_distance:
			best = p
			best_distance = distance
	return best


func _physics_process(delta: float) -> void:
	if player == null:
		return
	_time += delta
	for i in range(_chests.size() - 1, -1, -1):
		var chest := _chests[i]
		chest.offset.y = sin(_time * 4.0 + i) * 4.0
		var collector := _nearest_player(chest.position)
		if collector != null and chest.position.distance_to(collector.global_position) < CHEST_REACH:
			_chests.remove_at(i)
			chest.queue_free()
			Audio.play(&"chest", 0.0)
			chest_opened.emit(collector)
	_update_power_ups(delta)
	_update_coins(delta)
	for i in range(_pool.active.size() - 1, -1, -1):
		var soul: SoulGem = _pool.active[i]
		soul.animate(delta)
		var collector := _nearest_player(soul.position)
		if collector == null:
			continue
		var radius := collector.pickup_radius()
		var to_player := collector.global_position - soul.position
		var distance_squared := to_player.length_squared()
		if not soul.attracted and distance_squared < radius * radius:
			soul.attracted = true
			soul.fly_speed = POP_SPEED
		if not soul.attracted:
			continue
		soul.fly_speed = minf(soul.fly_speed + ACCELERATION * delta, MAX_FLY_SPEED)
		soul.position += to_player.normalized() * soul.fly_speed * delta
		# Grimoire: souls flying to a character hurt the enemies they cross, with that character's items.
		var soul_damage := collector.inventory.soul_damage() if collector.inventory != null else 0.0
		if soul_damage > 0.0:
			_soul_hits(soul, soul_damage, delta, collector)
		if distance_squared < COLLECT_DISTANCE * COLLECT_DISTANCE:
			var value := soul.value
			_pool.release(soul)
			Audio.play(&"pickup", 0.12, -6.0)
			Events.xp_collected.emit(value)
			collected.emit(value, collector)


func _update_power_ups(delta: float) -> void:
	for i in range(_power_ups.size() - 1, -1, -1):
		var power_up := _power_ups[i]
		var life: float = power_up.get_meta(&"life") - delta
		power_up.set_meta(&"life", life)
		power_up.offset.y = sin(_time * 3.0 + i) * 5.0
		# Blinks during its last 5 seconds.
		power_up.visible = life > 5.0 or fmod(life, 0.3) > 0.12
		var collector := _nearest_player(power_up.position)
		if collector != null and power_up.position.distance_to(collector.global_position) < POWER_UP_REACH:
			var kind: StringName = power_up.get_meta(&"kind")
			_power_ups.remove_at(i)
			power_up.queue_free()
			Audio.play(&"powerup", 0.0)
			power_up_collected.emit(kind)
		elif life <= 0.0:
			_power_ups.remove_at(i)
			power_up.queue_free()


func _update_coins(delta: float) -> void:
	for i in range(_coins.active.size() - 1, -1, -1):
		var coin: Coin = _coins.active[i]
		coin.animate(delta)
		var collector := _nearest_player(coin.position)
		if collector == null:
			continue
		var radius := collector.pickup_radius()
		var to_player := collector.global_position - coin.position
		var distance_squared := to_player.length_squared()
		if not coin.attracted and distance_squared < radius * radius:
			coin.attracted = true
			coin.fly_speed = POP_SPEED
		if not coin.attracted:
			continue
		coin.fly_speed = minf(coin.fly_speed + ACCELERATION * delta, MAX_FLY_SPEED)
		coin.position += to_player.normalized() * coin.fly_speed * delta
		if distance_squared < COLLECT_DISTANCE * COLLECT_DISTANCE:
			_coins.release(coin)
			Audio.play(&"coin", 0.1, -6.0)
			gold_collected.emit(1, collector)


## Souls flying to the player hurt the enemies they cross (grimoire item).
func _soul_hits(soul: SoulGem, damage: float, delta: float, collector: Player) -> void:
	var cooldown: float = soul.get_meta(&"hit_cooldown", 0.0) - delta
	if cooldown > 0.0:
		soul.set_meta(&"hit_cooldown", cooldown)
		return
	var hit := enemies.in_radius(soul.position, SOUL_HIT_RADIUS)
	if hit.is_empty():
		soul.set_meta(&"hit_cooldown", 0.0)
		return
	soul.set_meta(&"hit_cooldown", SOUL_HIT_INTERVAL)
	for enemy in hit:
		enemies.damage(enemy, damage, Vector2.ZERO, 0.0, EnemyManager.SOURCE_ITEM, collector)
