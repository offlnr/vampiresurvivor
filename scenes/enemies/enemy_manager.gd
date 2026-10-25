class_name EnemyManager
extends Node2D
## Spawns enemies from the wave table, periodic hordes and a boss every few minutes, moves them towards the player,
## keeps them apart and applies damage. Enemies are found with a spatial grid instead of physics.

## A boss is about to arrive, has arrived, or has been beaten.
signal boss_warning(title: String)
signal boss_started(title: String)
signal boss_defeated(data: EnemyData, position: Vector2)
signal horde_warning(title: String)
signal horde_started(title: String)

enum HordeKind { RING, SWARM, CHARGE }

const ENEMY_SCENE := preload("res://scenes/enemies/enemy.tscn")
## Grid queries reach this far beyond their radius to find enemies whose body overlaps it. Bigger
## enemies (elite golems, bosses) are kept apart in `_big` and always checked.
const MAX_ENEMY_RADIUS := 40.0
## Never more than this many enemies alive, hordes included.
const HARD_CAP := 400
const SEPARATION_STRENGTH := 9.0
const KNOCKBACK_DECAY := 9.0
const SPAWN_MARGIN := 70.0
const POTION_TEXTURE := preload("res://art/placeholder/potion.svg")
const POTION_LIFE := 4.0
const POTION_HIT_RADIUS := 14.0
## Explosions hurt the player within this multiple of the bomber's trigger range.
const EXPLOSION_REACH := 1.8
## Past the last row of the wave table, difficulty keeps growing every minute from here.
const ENDLESS_START := 600.0
const ENDLESS_HEALTH_GROWTH := 1.35
const ENDLESS_DAMAGE_GROWTH := 0.3
const ENDLESS_SPEED_GROWTH := 0.03
## From the very start, enemies get faster every minute, with no cap.
const SPEED_GROWTH_PER_MINUTE := 0.02
## As in Megabonk, enemies get stronger with time (and Difficulty), not with the player's level:
## health follows the wave table and damage grows this much per minute.
const DAMAGE_GROWTH_PER_MINUTE := 0.08
const ENDLESS_SPAWN_SPEEDUP := 0.06
const ENDLESS_MIN_INTERVAL := 0.5
const ENDLESS_EXTRA_ALIVE := 25
const HORDE_INTERVAL := 60.0
## No hordes before this time, so the player can gear up first.
const FIRST_HORDE_TIME := 180.0
const HORDE_WARNING_TIME := 3.0
const HORDE_TITLES := ["Anillo de zombis", "Enjambre de murciélagos", "Carga de fantasmas"]
const SWARM_SPEED := 270.0
const SWARM_LIFE := 9.0
## Where damage comes from: only weapon hits trigger on-hit items.
const SOURCE_WEAPON := 0
const SOURCE_ITEM := 1
const ELITE_COINS := 8
## A boss arrives every this many seconds (if the last one is dead), announced a few seconds before.
const BOSS_INTERVAL := 300.0
const BOSS_WARNING_TIME := 5.0
const BOSSES: Array[EnemyData] = [
	preload("res://data/enemies/jefe_golem.tres"),
	preload("res://data/enemies/jefe_bruja.tres"),
	preload("res://data/enemies/jefe_calabaza.tres"),
]
## Each round of bosses (after the three) has this much more health, on top of the time scaling.
const BOSS_ROUND_HEALTH := 0.5
const BOSS_SLAM_TIME := 1.2
const BOSS_SLAM_RADIUS := 210.0
const BOSS_RING_POTIONS := 14
## Each potion of a ring hurts this share of the boss's attack damage (the slam hurts it all).
const BOSS_RING_DAMAGE := 0.4
const BOSS_SUMMONS := 7
const BOSS_COINS := 30
## Share of a boss's health the bomb power-up takes (elites lose BOMB_ELITE_DAMAGE).
const BOSS_BOMB_SHARE := 0.04

@export var wave_table: WaveTable
@export var bat: EnemyData
@export var zombie: EnemyData
@export var ghost: EnemyData

var player: Player
## Every character the enemies hunt: the player, plus the guest's in online co-op. Empty means just `player`.
var players: Array[Player] = []
var effects: Effects
var pickups: PickupManager
var inventory: Inventory
var decorations: Decorations
## While above zero, enemies don't move, spawn or hurt the player (clock power-up).
var time_stop_left := 0.0
## While above zero, no new enemies spawn and hordes wait (after the bomb power-up).
var spawn_pause_left := 0.0
## Seconds since the run started; set by the run every frame.
var run_time := 0.0
## Multiplies enemy health, damage and how many can be alive (cauldrons raise it).
var difficulty := 1.0
## Online co-op: two characters hit twice as hard, so enemies get this much more health.
var coop_health := 1.0
## Online co-op: this many times more enemies can be alive.
var coop_count := 1.0
var spawning_enabled := true
var grid := SpatialGrid.new(64.0)

var _pool: ObjectPool
var _spawn_left := 0.5
var _normal_alive := 0
var _next_horde_time := FIRST_HORDE_TIME
var _horde_warned := false
var _horde_count := 0
var _potions: Array[Sprite2D] = []
var _big: Array[Enemy] = []
## The boss on the map, or null.
var boss: Enemy
var _boss_count := 0
var _next_boss_time := BOSS_INTERVAL
var _boss_warned := false


func _ready() -> void:
	_pool = ObjectPool.new(ENEMY_SCENE.instantiate, self)


func active() -> Array:
	return _pool.active


func count() -> int:
	return _pool.active.size()


func pool_size() -> int:
	return _pool.size()


func current_wave() -> WaveEntry:
	return wave_table.entry_at(run_time)


## Minutes played beyond the end of the wave table.
func endless_minutes() -> float:
	return maxf(run_time - ENDLESS_START, 0.0) / 60.0


func health_multiplier() -> float:
	return current_wave().health_multiplier * pow(ENDLESS_HEALTH_GROWTH, endless_minutes()) * difficulty * coop_health


func damage_multiplier() -> float:
	var by_time := 1.0 + DAMAGE_GROWTH_PER_MINUTE * run_time / 60.0
	return by_time * (1.0 + ENDLESS_DAMAGE_GROWTH * endless_minutes()) * difficulty


func speed_multiplier() -> float:
	var minutes := run_time / 60.0
	return current_wave().speed_multiplier * (1.0 + SPEED_GROWTH_PER_MINUTE * minutes) * (1.0 + ENDLESS_SPEED_GROWTH * endless_minutes())


func spawn_interval() -> float:
	return current_wave().spawn_interval * maxf(1.0 - ENDLESS_SPAWN_SPEEDUP * endless_minutes(), ENDLESS_MIN_INTERVAL)


func max_alive() -> int:
	var alive := (current_wave().max_alive + ENDLESS_EXTRA_ALIVE * endless_minutes()) * difficulty * coop_count
	return mini(int(alive), HARD_CAP)


func next_horde_kind() -> int:
	return _horde_count % HordeKind.size()


func _physics_process(delta: float) -> void:
	if player == null:
		return
	_rebuild_grid()
	_move(delta)
	_move_potions(delta)
	if time_stop_left > 0.0:
		time_stop_left -= delta
		# The horde schedule waits while time is stopped.
		_next_horde_time += delta
	elif spawn_pause_left > 0.0:
		spawn_pause_left -= delta
		_next_horde_time += delta
	elif spawning_enabled and any_player_alive():
		_spawn_tick(delta)
		_horde_tick()
		_boss_tick()
	_relocate_far_enemies()


func _rebuild_grid() -> void:
	grid.clear()
	_big.clear()
	for enemy: Enemy in _pool.active:
		grid.insert(enemy, enemy.position)
		if enemy.radius > MAX_ENEMY_RADIUS:
			_big.append(enemy)


func _move(delta: float) -> void:
	var keep_out := Player.BODY_RADIUS * 0.8
	var stopped := time_stop_left > 0.0
	for i in range(_pool.active.size() - 1, -1, -1):
		if i >= _pool.active.size():
			continue
		var enemy: Enemy = _pool.active[i]
		if enemy.poison_left > 0.0:
			enemy.poison_left -= delta
			enemy.poison_tick -= delta
			if enemy.poison_tick <= 0.0:
				enemy.poison_tick = 0.5
				damage(enemy, enemy.poison_dps * 0.5, Vector2.ZERO, 0.0, SOURCE_ITEM)
				if not enemy.alive:
					continue
		if stopped or enemy.frozen_left > 0.0:
			enemy.frozen_left = maxf(enemy.frozen_left - delta, 0.0)
			enemy.animate(delta, 0.0, true)
			continue
		if enemy.fixed_velocity != Vector2.ZERO:
			enemy.life_left -= delta
			if enemy.life_left <= 0.0:
				_release(enemy)
				continue
			enemy.position += enemy.fixed_velocity * delta
			enemy.animate(delta, enemy.fixed_velocity.x)
			continue
		if enemy.is_spawning():
			enemy.animate(delta, 0.0)
			continue

		var to_player := nearest_player(enemy.position).global_position - enemy.position
		var distance := to_player.length()
		var direction := to_player / distance if distance > 0.01 else Vector2.ZERO
		var velocity := direction * enemy.speed
		if distance < enemy.radius + keep_out:
			velocity = Vector2.ZERO

		if enemy.is_boss:
			velocity = _boss_act(enemy, delta, velocity)
		match enemy.data.behavior if not enemy.is_boss else EnemyData.Behavior.CHASE:
			EnemyData.Behavior.EXPLODER:
				if distance < enemy.data.attack_range:
					_explode(enemy)
					continue
			EnemyData.Behavior.RANGED:
				enemy.attack_left -= delta
				if distance < enemy.data.attack_range:
					# Stops at throwing distance, and backs off if the player comes too close.
					velocity = -direction * enemy.speed * 0.6 if distance < enemy.data.attack_range * 0.6 else Vector2.ZERO
					if enemy.attack_left <= 0.0:
						enemy.attack_left = enemy.data.attack_cooldown
						_throw_potion(enemy, direction)

		var push := Vector2.ZERO
		for other: Enemy in grid.query(enemy.position, enemy.radius + MAX_ENEMY_RADIUS):
			if other == enemy or other.fixed_velocity != Vector2.ZERO:
				continue
			var offset := enemy.position - other.position
			var min_distance := enemy.radius + other.radius
			var length_squared := offset.length_squared()
			if length_squared < min_distance * min_distance:
				if length_squared < 0.0001:
					offset = Vector2.from_angle(randf() * TAU)
					length_squared = 1.0
				var length := sqrt(length_squared)
				# Elites shove the small fry aside instead of being blocked by them.
				var weight := 0.2 if enemy.is_elite and not other.is_elite else 1.0
				push += offset / length * (min_distance - length) * weight

		enemy.position += (velocity + enemy.knockback) * delta + push * SEPARATION_STRENGTH * delta
		if decorations != null and not enemy.data.flying:
			# Walking enemies go around solid props, sliding along them towards the player.
			enemy.position = decorations.push_out(enemy.position, enemy.radius * 0.8)
		enemy.knockback = enemy.knockback.lerp(Vector2.ZERO, minf(KNOCKBACK_DECAY * delta, 1.0))
		enemy.animate(delta, direction.x)


func _spawn_tick(delta: float) -> void:
	var wave := current_wave()
	_spawn_left -= delta
	if _spawn_left > 0.0:
		return
	_spawn_left = spawn_interval()
	var cap := max_alive()
	for i in wave.spawn_batch:
		if _normal_alive >= cap or count() >= HARD_CAP:
			break
		spawn(wave.pick_enemy(), offscreen_point(randf() * TAU, spawn_anchor()), health_multiplier())


func spawn(enemy_data: EnemyData, pos: Vector2, health_multiplier := 1.0, elite := false, horde := false,
		is_boss := false) -> Enemy:
	var enemy: Enemy = _pool.acquire()
	enemy.setup(enemy_data, health_multiplier, elite, speed_multiplier(), damage_multiplier(), is_boss)
	enemy.is_horde = horde
	enemy.position = pos
	if not horde:
		_normal_alive += 1
	return enemy


## Spawns `amount` enemies of the current wave around the player, ignoring the wave limit.
func spawn_burst(amount: int) -> void:
	var wave := current_wave()
	for i in amount:
		if count() >= HARD_CAP:
			return
		spawn(wave.pick_enemy(), offscreen_point(randf() * TAU, spawn_anchor()), health_multiplier(), false, true)


# --- Hordes -----------------------------------------------------------------

func _horde_tick() -> void:
	if not _horde_warned and run_time >= _next_horde_time - HORDE_WARNING_TIME:
		_horde_warned = true
		horde_warning.emit(HORDE_TITLES[next_horde_kind()])
		Audio.play(&"alert", 0.0)
	if run_time >= _next_horde_time:
		start_horde()


## Starts the next horde now. Also used by the debug panel.
func start_horde() -> void:
	var kind := next_horde_kind()
	# Each horde is bigger than the last.
	var n := _horde_count
	var health := health_multiplier()
	match kind:
		HordeKind.RING:
			_spawn_ring(mini(18 + 8 * n, 64), health)
		HordeKind.SWARM:
			_spawn_swarm(mini(28 + 8 * n, 80), health)
		HordeKind.CHARGE:
			_spawn_charge(mini(13 + 5 * n, 45), health)
	horde_started.emit(HORDE_TITLES[kind])
	_horde_count += 1
	_next_horde_time = _horde_time_after(run_time)
	_horde_warned = false


## Keeps the horde and boss schedules consistent after the run time jumps (debug).
func sync_horde_clock() -> void:
	_next_horde_time = _horde_time_after(run_time)
	_horde_warned = false
	_next_boss_time = (floorf(run_time / BOSS_INTERVAL) + 1.0) * BOSS_INTERVAL
	_boss_warned = false


# --- Bosses -----------------------------------------------------------------

func next_boss() -> EnemyData:
	return BOSSES[_boss_count % BOSSES.size()]


func _boss_tick() -> void:
	if boss != null:
		# The next one waits until this one is beaten.
		_next_boss_time = maxf(_next_boss_time, run_time + BOSS_WARNING_TIME + 1.0)
		return
	if not _boss_warned and run_time >= _next_boss_time - BOSS_WARNING_TIME:
		_boss_warned = true
		boss_warning.emit(next_boss().display_name)
		Audio.play(&"alert", 0.0)
	if run_time >= _next_boss_time:
		start_boss()


## Brings the next boss now, from just outside the screen. Also used by the debug panel.
func start_boss() -> void:
	if boss != null:
		return
	var data := next_boss()
	var round_bonus := 1.0 + BOSS_ROUND_HEALTH * floorf(_boss_count / float(BOSSES.size()))
	var anchor := spawn_anchor()
	boss = spawn(data, offscreen_point(randf() * TAU, anchor), health_multiplier() * round_bonus, true, true, true)
	_boss_count += 1
	_next_boss_time = (floorf(run_time / BOSS_INTERVAL) + 1.0) * BOSS_INTERVAL
	_boss_warned = false
	boss_started.emit(data.display_name)


## The boss walks towards the nearest player and, every `attack_cooldown` seconds, uses its next
## attack. It stands still while charging a slam.
func _boss_act(enemy: Enemy, delta: float, velocity: Vector2) -> Vector2:
	if enemy.slam_left > 0.0:
		if enemy.charge_slam(delta):
			_slam(enemy)
		return Vector2.ZERO
	enemy.attack_left -= delta
	var attacks := enemy.data.boss_attacks
	if enemy.attack_left > 0.0 or attacks.is_empty():
		return velocity
	enemy.attack_left = enemy.data.attack_cooldown
	var attack: int = attacks[enemy.boss_attack % attacks.size()]
	enemy.boss_attack += 1
	match attack:
		EnemyData.BossAttack.RING:
			var start := randf() * TAU
			for i in BOSS_RING_POTIONS:
				_throw_potion(enemy, Vector2.from_angle(start + TAU * i / BOSS_RING_POTIONS), BOSS_RING_DAMAGE)
			Audio.play(&"throw", 0.1)
		EnemyData.BossAttack.SLAM:
			enemy.start_slam(BOSS_SLAM_TIME, BOSS_SLAM_RADIUS)
			Audio.play(&"alert", 0.1, -6.0)
			return Vector2.ZERO
		EnemyData.BossAttack.SUMMON:
			var wave := current_wave()
			for i in BOSS_SUMMONS:
				if count() >= HARD_CAP:
					break
				var pos := enemy.position + Vector2.from_angle(TAU * i / BOSS_SUMMONS) * (enemy.radius + 60.0)
				spawn(wave.pick_enemy(), pos, health_multiplier(), false, true)
				effects.puff(pos, Palette.PURPLE_LIGHT)
	return velocity


func _slam(enemy: Enemy) -> void:
	effects.shockwave(enemy.position, Palette.RED, enemy.slam_radius / 40.0)
	Audio.play(&"boom", 0.1)
	for p in all_players():
		if enemy.position.distance_to(p.global_position) <= enemy.slam_radius + Player.BODY_RADIUS:
			p.take_damage(enemy.data.attack_damage * enemy.damage_multiplier)


func _horde_time_after(time: float) -> float:
	return maxf(FIRST_HORDE_TIME, (floorf(time / HORDE_INTERVAL) + 1.0) * HORDE_INTERVAL)


func _spawn_ring(amount: int, health: float) -> void:
	var half := visible_half_extents()
	var radius := half.length() + SPAWN_MARGIN
	var start := randf() * TAU
	var center := spawn_anchor().global_position
	for i in amount:
		if count() >= HARD_CAP:
			break
		var angle := start + TAU * i / amount
		spawn(zombie, center + Vector2.from_angle(angle) * radius, health, false, true)
	spawn(zombie, center + Vector2.from_angle(start + PI / amount) * (radius + 40.0), health, true, true)


func _spawn_swarm(amount: int, health: float) -> void:
	var angle := randf() * TAU
	var side := Vector2.from_angle(angle)
	var across := side.orthogonal()
	var half := visible_half_extents()
	var origin := offscreen_point(angle, spawn_anchor()) + side * 40.0
	var width := maxf(half.x, half.y) * 1.6
	for i in amount:
		if count() >= HARD_CAP:
			break
		var offset := across * randf_range(-width / 2.0, width / 2.0) + side * randf_range(0.0, 260.0)
		var enemy := spawn(bat, origin + offset, health, false, true)
		enemy.fixed_velocity = -side * SWARM_SPEED * randf_range(0.9, 1.1)
		enemy.life_left = SWARM_LIFE
	spawn(bat, origin, health, true, true)


func _spawn_charge(amount: int, health: float) -> void:
	var angle := randf() * TAU
	var side := Vector2.from_angle(angle)
	var across := side.orthogonal()
	var origin := offscreen_point(angle, spawn_anchor())
	for i in amount:
		if count() >= HARD_CAP:
			break
		var spread := (i - amount / 2.0) * 34.0
		spawn(ghost, origin + across * spread + side * randf_range(0.0, 60.0), health, false, true)
	spawn(ghost, origin + side * 80.0, health, true, true)


# --- Queries ----------------------------------------------------------------

func visible_half_extents() -> Vector2:
	return get_viewport_rect().size / player.camera.zoom * 0.5


## A point just outside the visible area, in the given direction from `around` (the player by default).
func offscreen_point(angle: float, around: Player = null) -> Vector2:
	var half := visible_half_extents()
	var direction := Vector2.from_angle(angle)
	var to_edge := minf(half.x / maxf(absf(direction.x), 0.001), half.y / maxf(absf(direction.y), 0.001))
	return (around if around != null else player).global_position + direction * (to_edge + SPAWN_MARGIN)


func all_players() -> Array[Player]:
	if players.is_empty():
		return [player]
	return players


func any_player_alive() -> bool:
	for p in all_players():
		if not p.is_dead:
			return true
	return false


## The living character nearest to `pos` (the player when everyone is dead).
func nearest_player(pos: Vector2) -> Player:
	var best := player
	var best_distance := INF
	for p in all_players():
		var distance := p.global_position.distance_squared_to(pos)
		if not p.is_dead and distance < best_distance:
			best = p
			best_distance = distance
	return best


## A random living character for new enemies to appear around, so in co-op both get company.
func spawn_anchor() -> Player:
	var alive: Array[Player] = []
	for p in all_players():
		if not p.is_dead:
			alive.append(p)
	return alive.pick_random() if not alive.is_empty() else player


func _relocate_far_enemies() -> void:
	var half := visible_half_extents()
	var limit := maxf(half.x, half.y) * 4.0
	for enemy: Enemy in _pool.active:
		if enemy.fixed_velocity != Vector2.ZERO:
			continue
		if enemy.position.distance_to(nearest_player(enemy.position).global_position) > limit:
			var anchor := spawn_anchor()
			enemy.position = offscreen_point(anchor.last_move_direction.angle() + randf_range(-1.0, 1.0), anchor)


func contact_damage_at(pos: Vector2, radius: float) -> float:
	var damage := 0.0
	if time_stop_left > 0.0:
		return damage
	for enemy in in_radius(pos, radius):
		if not enemy.is_spawning() and enemy.frozen_left <= 0.0:
			damage = maxf(damage, enemy.contact_damage)
	return damage


## Living enemies whose body overlaps the circle.
func in_radius(pos: Vector2, radius: float) -> Array[Enemy]:
	var result: Array[Enemy] = []
	for enemy: Enemy in grid.query(pos, radius + MAX_ENEMY_RADIUS):
		if enemy.alive and enemy.radius <= MAX_ENEMY_RADIUS and _overlaps(enemy, pos, radius):
			result.append(enemy)
	for enemy in _big:
		if enemy.alive and _overlaps(enemy, pos, radius):
			result.append(enemy)
	return result


static func _overlaps(enemy: Enemy, pos: Vector2, radius: float) -> bool:
	var reach := radius + enemy.radius
	return enemy.position.distance_squared_to(pos) <= reach * reach


## Up to `amount` living enemies within `max_distance`, nearest first.
func nearest(pos: Vector2, max_distance: float, amount := 1) -> Array[Enemy]:
	var candidates := []
	var max_squared := max_distance * max_distance
	for enemy: Enemy in _pool.active:
		var distance_squared := enemy.position.distance_squared_to(pos)
		if distance_squared <= max_squared:
			candidates.append([distance_squared, enemy])
	candidates.sort_custom(func(a, b): return a[0] < b[0])
	var result: Array[Enemy] = []
	for i in mini(amount, candidates.size()):
		result.append(candidates[i][1])
	return result


## Living enemies currently on screen, in random order.
func on_screen() -> Array[Enemy]:
	var half := visible_half_extents()
	var view := Rect2(player.global_position - half, half * 2.0)
	var result: Array[Enemy] = []
	for enemy: Enemy in _pool.active:
		if enemy.alive and view.has_point(enemy.position):
			result.append(enemy)
	result.shuffle()
	return result


# --- Damage -----------------------------------------------------------------

## `attacker` is the character whose weapon or item hit (the player when unknown): its items,
## crits, lifesteal and knockback apply, which matters in online co-op.
func damage(enemy: Enemy, amount: float, push_direction := Vector2.ZERO, push_strength := 0.0, source := SOURCE_WEAPON,
		attacker: Player = null) -> void:
	if not enemy.alive:
		return
	var who := attacker if attacker != null else player
	var items: Inventory = who.inventory if who.inventory != null else inventory
	var critical := false
	if source == SOURCE_WEAPON and items != null:
		var bonus: Array = items.hit_multiplier(enemy)
		amount *= bonus[0]
		critical = bonus[1]
		if items.roll_crit():
			amount *= items.crit_multiplier()
			critical = true
	# Lifesteal only counts weapon damage the enemy actually had health for (no overkill).
	if source == SOURCE_WEAPON:
		who.on_damage_dealt(minf(amount, enemy.health))
	enemy.health -= amount
	enemy.flash()
	if push_strength > 0.0 and push_direction != Vector2.ZERO and not enemy.is_elite and not enemy.data.knockback_immune:
		var push := push_strength * (who.knockback_multiplier if source == SOURCE_WEAPON else 1.0)
		enemy.knockback += push_direction.normalized() * push
	var color := Palette.GOLD if critical else (Palette.GREEN if source == SOURCE_ITEM else Palette.BONE)
	effects.damage_number(enemy.position + Vector2(0, -enemy.radius * 2.0), amount, color, critical)
	Audio.play(&"hit", 0.15, -8.0)
	if enemy.health <= 0.0:
		_kill(enemy, items)
	elif source == SOURCE_WEAPON and items != null:
		items.on_weapon_hit(enemy, amount)


## Bomb power-up: no new enemies for `seconds`.
func pause_spawning(seconds: float) -> void:
	spawn_pause_left = maxf(spawn_pause_left, seconds)


## Clock power-up: freezes every enemy for `seconds`.
func stop_time(seconds: float) -> void:
	time_stop_left = maxf(time_stop_left, seconds)


## Bomb power-up: kills normal enemies on screen and hurts elites.
func detonate(elite_fraction: float) -> void:
	for enemy in on_screen():
		if enemy.is_boss:
			damage(enemy, enemy.max_health * BOSS_BOMB_SHARE, Vector2.ZERO, 0.0, SOURCE_ITEM)
		elif enemy.is_elite:
			damage(enemy, enemy.max_health * elite_fraction, Vector2.ZERO, 0.0, SOURCE_ITEM)
		else:
			damage(enemy, enemy.health + 1.0, Vector2.ZERO, 0.0, SOURCE_ITEM)


func _explode(enemy: Enemy) -> void:
	effects.shockwave(enemy.position, Palette.ORANGE, 1.6)
	Audio.play(&"boom", 0.1, -10.0)
	var reach := enemy.data.attack_range * EXPLOSION_REACH
	for p in all_players():
		if enemy.position.distance_to(p.global_position) <= reach:
			p.take_damage(enemy.data.attack_damage * enemy.damage_multiplier)
	_kill(enemy)


func _throw_potion(enemy: Enemy, direction: Vector2, damage_share := 1.0) -> void:
	var potion := Sprite2D.new()
	potion.texture = POTION_TEXTURE
	potion.position = enemy.position + Vector2(0, -enemy.radius)
	potion.z_index = 6
	potion.set_meta(&"velocity", direction * enemy.data.projectile_speed)
	potion.set_meta(&"damage", enemy.data.attack_damage * enemy.damage_multiplier * damage_share)
	potion.set_meta(&"life", POTION_LIFE)
	add_child(potion)
	_potions.append(potion)


func potion_count() -> int:
	return _potions.size()


func _move_potions(delta: float) -> void:
	var stopped := time_stop_left > 0.0
	for i in range(_potions.size() - 1, -1, -1):
		var potion := _potions[i]
		if stopped:
			continue
		var life: float = potion.get_meta(&"life") - delta
		potion.set_meta(&"life", life)
		var velocity: Vector2 = potion.get_meta(&"velocity")
		potion.position += velocity * delta
		potion.rotation += delta * 8.0
		var hit := false
		for p in all_players():
			if not p.is_dead and potion.position.distance_to(p.global_position) < Player.BODY_RADIUS + POTION_HIT_RADIUS:
				hit = true
				p.take_damage(potion.get_meta(&"damage"))
				effects.shockwave(potion.position, Palette.GREEN, 0.6)
				break
		if hit or life <= 0.0:
			_potions.remove_at(i)
			potion.queue_free()


func kill_all() -> void:
	for enemy: Enemy in _pool.active.duplicate():
		effects.death(enemy)
		_release(enemy)


func _kill(enemy: Enemy, items: Inventory = null) -> void:
	if items == null:
		items = inventory
	effects.death(enemy)
	pickups.spawn_soul(enemy.position, enemy.xp_value)
	if enemy.is_boss:
		# The reward is a choice for every player (see Run._on_boss_defeated).
		pickups.spawn_coins(enemy.position, BOSS_COINS)
		boss_defeated.emit(enemy.data, enemy.position)
	elif enemy.is_elite:
		pickups.spawn_chest(enemy.position)
		pickups.spawn_coins(enemy.position, ELITE_COINS)
		pickups.spawn_power_up(enemy.position + Vector2(40, 0), PowerUps.roll())
	else:
		if randf() < enemy.data.gold_chance:
			pickups.spawn_coins(enemy.position, 1)
		if randf() < PowerUps.DROP_CHANCE:
			pickups.spawn_power_up(enemy.position, PowerUps.roll())
	if items != null:
		items.on_kill(enemy)
	Audio.play(&"enemy_die", 0.15, -5.0)
	Events.enemy_killed.emit(enemy.data, enemy.position)
	_release(enemy)


func _release(enemy: Enemy) -> void:
	if enemy == boss:
		boss = null
	enemy.alive = false
	if not enemy.is_horde:
		_normal_alive -= 1
	enemy.queue_redraw()
	_pool.release(enemy)
