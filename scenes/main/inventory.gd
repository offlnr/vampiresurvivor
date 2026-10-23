class_name Inventory
extends Node2D
## Items the player owns and their effects: on weapon hit, on kill, when hurt, and periodic ones.

signal changed
## Gold won by an item (golden piggy bank); the run adds it like collected gold.
signal gold_gained(amount: int)

const POISON_DURATION := 3.0
## Share of the hit's damage dealt by the poison over its whole duration.
const POISON_SHARE := 0.6
const FREEZE_TIME := 1.5
const CLOUD_RADIUS := 85.0
const MIRROR_RADIUS := 170.0
const VOODOO_INTERVAL := 2.0
const VOODOO_RANGE := 260.0
## Voodoo curse damage, as a share of the player's strongest weapon hit.
const VOODOO_WEAPON_SHARE := 1.0
const EXECUTE_DAMAGE_BONUS := 0.01
const SPIRIT_TEXTURE := preload("res://art/placeholder/soul.svg")
## Spirit damage, as a share of the player's strongest weapon hit.
const SPIRIT_WEAPON_SHARE := 1.5
const SPIRIT_SPEED := 520.0
const SOUL_HIT_INTERVAL := 0.3
## Seconds between pulls of the magnet item with one copy; each copy divides it.
const AUTO_MAGNET_INTERVAL := 20.0
## Holy grimoire: health per second on top of its max health.
const HOLY_REGEN := 1.0
const FULL_HP_THRESHOLD := 0.9
const CLOSE_RANGE := 150.0
const BONK_MULTIPLIER := 20.0
## A megacrit deals this much instead of a crit's x2.
const MEGACRIT_MULTIPLIER := 4.0
const CRIT_HEAL_SHARE := 0.01
## Seconds standing still to reach the full idle damage bonus.
const IDLE_RAMP := 3.0
## Kills can raise damage by at most this much (demonic soul).
const KILL_DAMAGE_CAP := 1.0
const COWARD_TIME := 2.0
const SHROUD_TIME := 2.0
const SHOCK_RADIUS := 160.0
const MIASMA_RADIUS := 220.0
const LAST_STAND_TIME := 4.0
const EXPLOSION_RADIUS := 70.0
const EXPLOSION_SHARE := 0.65
const LIGHTNING_JUMPS := 3
const LIGHTNING_REACH := 140.0
const BURN_RADIUS := 70.0
## The funeral bell rings every this many seconds with one copy; each copy divides it.
const BELL_INTERVAL := 15.0
const BELL_FREEZE := 1.5

var player: Player
var enemies: EnemyManager
var pickups: PickupManager
var effects: Effects
## Item -> number of copies.
var stacks := {}
## Permanent damage won with executions this run.
var execute_bonus := 0.0
## Damage won by opening chests (cursed coin) and by kills (demonic soul) this run.
var chest_bonus := 0.0
var kill_bonus := 0.0
## Seconds the player has been standing still.
var idle_time := 0.0

var _per_effect := {}
var _voodoo_left := VOODOO_INTERVAL
var _magnet_left := AUTO_MAGNET_INTERVAL
var _bell_left := BELL_INTERVAL
var _spirits: Array[Sprite2D] = []


func add(item: ItemData) -> void:
	stacks[item] = stacks.get(item, 0) + 1
	_per_effect[item.effect] = _per_effect.get(item.effect, 0.0) + item.value
	_apply_stats(item, 1.0)
	changed.emit()


## Takes one copy away (the stopped hourglass breaks after saving the player).
func remove_one(item: ItemData) -> void:
	if not stacks.has(item):
		return
	stacks[item] -= 1
	if stacks[item] <= 0:
		stacks.erase(item)
	_per_effect[item.effect] = _per_effect.get(item.effect, 0.0) - item.value
	_apply_stats(item, -1.0)
	changed.emit()


## Items that are plain stats change the player directly, so the stats panel shows them too.
func _apply_stats(item: ItemData, sign: float) -> void:
	var v := item.value * sign
	match item.effect:
		ItemData.Effect.LUCK:
			player.luck += v
		ItemData.Effect.XP_GAIN:
			player.xp_multiplier += v
		ItemData.Effect.MAX_HP:
			player.increase_max_health(v)
		ItemData.Effect.REGEN:
			player.regen += v
		ItemData.Effect.DAMAGE:
			player.damage_multiplier += v
		ItemData.Effect.EVASION:
			player.evasion += v
		ItemData.Effect.LUCK_EVASION:
			player.luck += v
			player.evasion += v
		ItemData.Effect.PICKUP_RADIUS:
			player.pickup_multiplier += v
		ItemData.Effect.HOLY:
			player.increase_max_health(v)
			player.regen += HOLY_REGEN * sign
		ItemData.Effect.EXTRA_PROJECTILE:
			player.extra_amount += roundi(v)
			for weapon: Weapon in player.weapons.get_children():
				weapon.refresh()


func copies(item: ItemData) -> int:
	return stacks.get(item, 0)


## Sum of `value` over every copy of the items with this effect.
func amount(effect: ItemData.Effect) -> float:
	return _per_effect.get(effect, 0.0)


func damage_multiplier() -> float:
	var multiplier := 1.0 + execute_bonus + chest_bonus + kill_bonus
	var idle := amount(ItemData.Effect.IDLE_DAMAGE)
	if idle > 0.0:
		multiplier += idle * minf(idle_time / IDLE_RAMP, 1.0)
	var low_health := amount(ItemData.Effect.LOW_HP_DAMAGE)
	if low_health > 0.0:
		multiplier *= 1.0 + low_health * (1.0 - player.health / player.max_health)
	return multiplier


## Attack speed from items (cursed pocket watch), with no cap.
func attack_speed_bonus() -> float:
	var bonus := amount(ItemData.Effect.ATTACK_SPEED)
	if player.velocity != Vector2.ZERO:
		bonus += amount(ItemData.Effect.MOVING_ATTACK_SPEED)
	if player.has_buff(&"shroud"):
		bonus += amount(ItemData.Effect.DODGE_FRENZY)
	return bonus


func move_speed_bonus() -> float:
	var bonus := amount(ItemData.Effect.MOVE_SPEED) + amount(ItemData.Effect.COWARD)
	if player.has_buff(&"coward"):
		bonus += 0.3 * stacks_of(ItemData.Effect.COWARD)
	if player.has_buff(&"shroud"):
		bonus += amount(ItemData.Effect.DODGE_FRENZY)
	return bonus


## Copies owned of the items with this effect.
func stacks_of(effect: ItemData.Effect) -> int:
	var total := 0
	for item: ItemData in stacks:
		if item.effect == effect:
			total += stacks[item]
	return total


## Extra damage of one weapon hit on this enemy (owl monocle, hunter's stake, bone knuckles, mallet).
## Returns [multiplier, is_bonk].
func hit_multiplier(enemy: Enemy) -> Array:
	var multiplier := 1.0
	if enemy.health >= enemy.max_health * FULL_HP_THRESHOLD:
		multiplier += amount(ItemData.Effect.FULL_HP_DAMAGE)
	if enemy.is_elite:
		multiplier += amount(ItemData.Effect.ELITE_DAMAGE)
	if enemy.position.distance_to(player.global_position) <= CLOSE_RANGE:
		multiplier += amount(ItemData.Effect.CLOSE_DAMAGE)
	var bonk := randf() < amount(ItemData.Effect.BONK)
	if bonk:
		multiplier *= BONK_MULTIPLIER
	return [multiplier, bonk]


## Damage multiplier of a critical hit: x2, or x4 when it becomes a megacrit (devil's trident).
func crit_multiplier() -> float:
	if randf() < amount(ItemData.Effect.CRIT_HEAL):
		player.heal(player.max_health * CRIT_HEAL_SHARE)
	return MEGACRIT_MULTIPLIER if randf() < amount(ItemData.Effect.MEGACRIT) else 2.0


func on_chest_opened() -> void:
	chest_bonus += amount(ItemData.Effect.CHEST_DAMAGE)


## Chance that a paid chest opens for free (rusty key).
func free_chest() -> bool:
	return randf() < amount(ItemData.Effect.FREE_CHEST)


## Extra stats in weapon upgrades (cursed anvil).
func extra_upgrade_stats() -> int:
	return roundi(amount(ItemData.Effect.ANVIL))


## Stopped hourglass: saves the player from a lethal hit once per copy. True if it did.
func try_last_stand() -> bool:
	for item: ItemData in stacks:
		if item.effect == ItemData.Effect.LAST_STAND:
			remove_one(item)
			enemies.stop_time(LAST_STAND_TIME)
			player.add_buff(&"clock", LAST_STAND_TIME)
			effects.shockwave(player.global_position, Palette.GOLD, 4.0)
			Audio.play(&"tick", 0.0)
			return true
	return false


func on_player_dodged() -> void:
	if amount(ItemData.Effect.DODGE_FRENZY) > 0.0:
		player.add_buff(&"shroud", SHROUD_TIME)


func gold_bonus() -> float:
	return amount(ItemData.Effect.GOLD_GAIN)


## Critical chance from items (skull glasses) and the precision scroll.
func crit_chance() -> float:
	return amount(ItemData.Effect.CRIT) + player.crit_chance


func roll_crit() -> bool:
	return randf() < crit_chance()


## Called after a weapon hit that didn't kill the enemy.
func on_weapon_hit(enemy: Enemy, damage: float) -> void:
	if randf() < amount(ItemData.Effect.EXECUTE) and not enemy.is_elite:
		execute_bonus += EXECUTE_DAMAGE_BONUS
		effects.shockwave(enemy.position, Palette.RED, 0.8)
		enemies.damage(enemy, enemy.health + 1.0, Vector2.ZERO, 0.0, EnemyManager.SOURCE_ITEM, player)
		return
	if randf() < amount(ItemData.Effect.POISON_ON_HIT):
		enemy.poison(damage * POISON_SHARE / POISON_DURATION, POISON_DURATION)
	if randf() < amount(ItemData.Effect.FREEZE_ON_HIT):
		enemy.freeze(FREEZE_TIME)
	if randf() < amount(ItemData.Effect.POISON_CLOUD):
		effects.shockwave(enemy.position, Palette.GREEN, 0.9)
		for other in enemies.in_radius(enemy.position, CLOUD_RADIUS):
			other.poison(damage * POISON_SHARE / POISON_DURATION, POISON_DURATION)
	if randf() < amount(ItemData.Effect.ECHO):
		enemies.damage(enemy, damage, Vector2.ZERO, 0.0, EnemyManager.SOURCE_ITEM, player)
	if randf() < amount(ItemData.Effect.EXPLODE_ON_HIT):
		effects.shockwave(enemy.position, Palette.ORANGE, 1.0)
		for other in enemies.in_radius(enemy.position, EXPLOSION_RADIUS):
			if other != enemy:
				enemies.damage(other, damage * EXPLOSION_SHARE, other.position - enemy.position, 120.0, EnemyManager.SOURCE_ITEM, player)
	if randf() < amount(ItemData.Effect.LIGHTNING_ON_HIT):
		_lightning(enemy, damage)
	if randf() < amount(ItemData.Effect.BURN_ON_HIT):
		effects.shockwave(enemy.position, Palette.RED, 0.8)
		for other in enemies.in_radius(enemy.position, BURN_RADIUS):
			other.poison(damage / POISON_DURATION, POISON_DURATION)


func on_kill(enemy: Enemy) -> void:
	kill_bonus = minf(kill_bonus + amount(ItemData.Effect.KILL_DAMAGE), KILL_DAMAGE_CAP)
	if randf() < amount(ItemData.Effect.CANDY_ON_KILL):
		pickups.spawn_power_up(enemy.position, &"candy")
	var heal := amount(ItemData.Effect.HEAL_ON_KILL)
	if heal > 0.0:
		player.heal(player.max_health * heal)
	if randf() < amount(ItemData.Effect.SOUL_HARVEST):
		_release_spirit(enemy.position)


func on_player_hurt(damage: float) -> void:
	if amount(ItemData.Effect.COWARD) > 0.0:
		player.add_buff(&"coward", COWARD_TIME)
	var gold := roundi(amount(ItemData.Effect.GOLD_ON_HURT))
	if gold > 0:
		gold_gained.emit(gold)
	var shock := amount(ItemData.Effect.SHOCK_ON_HURT)
	if shock > 0.0:
		effects.shockwave(player.global_position, Color("6cc8ff"), 1.6)
		for enemy in enemies.in_radius(player.global_position, SHOCK_RADIUS):
			enemies.damage(enemy, strongest_hit() * shock, enemy.position - player.global_position, 160.0, EnemyManager.SOURCE_ITEM, player)
	var miasma := amount(ItemData.Effect.POISON_ON_HURT)
	if miasma > 0.0:
		effects.shockwave(player.global_position, Palette.GREEN, 2.2)
		for enemy in enemies.in_radius(player.global_position, MIASMA_RADIUS):
			enemy.poison(strongest_hit() * miasma / POISON_DURATION, POISON_DURATION)
	var reflect := amount(ItemData.Effect.MIRROR)
	if reflect <= 0.0:
		return
	effects.shockwave(player.global_position, Palette.PURPLE_LIGHT, 1.4)
	for enemy in enemies.in_radius(player.global_position, MIRROR_RADIUS):
		enemies.damage(enemy, damage * reflect, enemy.position - player.global_position, 200.0, EnemyManager.SOURCE_ITEM, player)


## Damage of souls flying to the player (grimoire), from the strongest weapon hit. 0 if none.
func soul_damage() -> float:
	var share := amount(ItemData.Effect.SOUL_DAMAGE)
	return share * strongest_hit() if share > 0.0 else 0.0


## Damage of the player's strongest weapon hit right now; item effects scale with it,
## so they keep up with endless enemy scaling without trivialising it.
func strongest_hit() -> float:
	var best := 0.0
	for weapon: Weapon in player.weapons.get_children():
		best = maxf(best, weapon.damage())
	return best


func _physics_process(delta: float) -> void:
	if player == null or player.is_dead:
		return
	idle_time = idle_time + delta if player.velocity == Vector2.ZERO else 0.0
	var campfire := amount(ItemData.Effect.IDLE_HEAL)
	if campfire > 0.0 and idle_time > 0.5:
		player.heal(player.max_health * campfire * delta)
	var bells := amount(ItemData.Effect.BELL)
	if bells > 0.0:
		_bell_left -= delta
		if _bell_left <= 0.0:
			_bell_left = BELL_INTERVAL / bells
			_ring_bell()
	var dolls := amount(ItemData.Effect.VOODOO)
	if dolls > 0.0:
		_voodoo_left -= delta
		if _voodoo_left <= 0.0:
			_voodoo_left = VOODOO_INTERVAL
			_voodoo(int(dolls))
	var magnets := amount(ItemData.Effect.AUTO_MAGNET)
	if magnets > 0.0:
		_magnet_left -= delta
		if _magnet_left <= 0.0:
			_magnet_left = AUTO_MAGNET_INTERVAL / magnets
			effects.shockwave(player.global_position, Palette.GREEN, 2.0)
			pickups.attract_all()
	_move_spirits(delta)


## Funeral bell: every enemy on screen freezes for a moment.
func _ring_bell() -> void:
	effects.shockwave(player.global_position, Palette.PURPLE_LIGHT, 7.0)
	Audio.play(&"tick", 0.0, -2.0)
	for enemy in enemies.on_screen():
		enemy.freeze(BELL_FREEZE)


## Storm orb: a bolt that jumps from the hit enemy to a few others nearby.
func _lightning(first: Enemy, damage: float) -> void:
	var points := PackedVector2Array([first.position + Vector2(0, -200)])
	var hit := {}
	var current := first
	while current != null and hit.size() <= LIGHTNING_JUMPS:
		hit[current] = true
		points.append(current.position)
		var from := current.position
		if current != first:
			enemies.damage(current, damage, Vector2.ZERO, 0.0, EnemyManager.SOURCE_ITEM, player)
		current = null
		for other in enemies.nearest(from, LIGHTNING_REACH, 5):
			if not hit.has(other) and other.alive:
				current = other
				break
	enemies.damage(first, damage, Vector2.ZERO, 0.0, EnemyManager.SOURCE_ITEM, player)
	var line := Line2D.new()
	line.points = points
	line.width = 3.0
	line.default_color = Color("b9f3ff")
	line.z_index = 8
	add_child(line)
	var tween := line.create_tween()
	tween.tween_property(line, "modulate:a", 0.0, 0.2)
	tween.tween_callback(line.queue_free)
	Audio.play(&"lightning", 0.15, -12.0)


func _voodoo(extra_targets: int) -> void:
	var hit := strongest_hit() * VOODOO_WEAPON_SHARE
	for enemy in enemies.nearest(player.global_position, VOODOO_RANGE, 2 + extra_targets):
		effects.shockwave(enemy.position, Palette.PURPLE_LIGHT, 0.5)
		enemies.damage(enemy, hit, Vector2.ZERO, 0.0, EnemyManager.SOURCE_ITEM, player)


func _release_spirit(pos: Vector2) -> void:
	var spirit := Sprite2D.new()
	spirit.texture = SPIRIT_TEXTURE
	spirit.modulate = Palette.GREEN
	spirit.scale = Vector2.ONE * 0.8
	spirit.position = pos
	spirit.z_index = 8
	spirit.set_meta(&"life", 3.0)
	add_child(spirit)
	_spirits.append(spirit)


func _move_spirits(delta: float) -> void:
	for i in range(_spirits.size() - 1, -1, -1):
		var spirit := _spirits[i]
		var life: float = spirit.get_meta(&"life") - delta
		spirit.set_meta(&"life", life)
		var targets := enemies.nearest(spirit.position, 900.0, 1)
		if life <= 0.0 or targets.is_empty():
			_spirits.remove_at(i)
			spirit.queue_free()
			continue
		var target: Enemy = targets[0]
		spirit.position = spirit.position.move_toward(target.position, SPIRIT_SPEED * delta)
		spirit.rotation = sin(life * 10.0) * 0.3
		if spirit.position.distance_to(target.position) < target.radius + 8.0:
			enemies.damage(target, strongest_hit() * SPIRIT_WEAPON_SHARE, Vector2.ZERO, 0.0, EnemyManager.SOURCE_ITEM, player)
			_spirits.remove_at(i)
			spirit.queue_free()
