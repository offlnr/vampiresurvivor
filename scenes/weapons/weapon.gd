class_name Weapon
extends Node2D
## Base class for weapons that attack on their own every cooldown.

var data: WeaponData
var level := 1
## Accumulated upgrades: stat -> total bonus (see WeaponData.upgrade_stats).
var bonuses := {}
var player: Player
var enemies: EnemyManager
## World-space container for nodes that must not follow the player (projectiles).
var projectiles_root: Node2D

var _cooldown_left := 0.4


func setup(weapon_data: WeaponData, owner_player: Player, enemy_manager: EnemyManager, projectiles: Node2D) -> void:
	data = weapon_data
	player = owner_player
	enemies = enemy_manager
	projectiles_root = projectiles
	_on_setup()
	_on_level_changed()


## Current value of a stat: the weapon's base plus its upgrades.
func stat(stat_name: StringName) -> float:
	match stat_name:
		&"damage":
			return data.damage * (1.0 + bonuses.get(&"damage", 0.0))
		&"cooldown":
			return data.cooldown / (1.0 + bonuses.get(&"attack_speed", 0.0))
		&"amount":
			# Always a whole number: upgrades and scrolls only add whole projectiles.
			return data.amount + bonuses.get(&"amount", 0.0) + (player.extra_amount if player != null else 0)
		&"pierce":
			return data.pierce + bonuses.get(&"pierce", 0.0)
		&"area":
			return data.area * (1.0 + bonuses.get(&"area", 0.0))
		&"duration":
			return data.duration * (1.0 + bonuses.get(&"duration", 0.0)) * (player.duration_multiplier if player != null else 1.0)
		&"speed":
			return data.speed * (1.0 + bonuses.get(&"speed", 0.0)) * (player.projectile_speed_multiplier if player != null else 1.0)
	return 0.0


## Stats an upgrade of this weapon can improve. Nothing has a cap.
func upgradeable_stats() -> Array[StringName]:
	return data.upgrade_stats.duplicate()


## Rolls an upgrade like Megabonk: 1 or 2 stats if common, 2 otherwise, each value scaled only by rarity.
func roll_upgrade(rarity: int) -> Dictionary:
	var pool := upgradeable_stats()
	pool.shuffle()
	var upgrade := {}
	# As in Megabonk: a common upgrade improves 1 or 2 stats (even odds), any other rarity 2.
	var count := (1 if randf() < 0.5 else 2) if rarity == Rarity.Tier.COMMON else 2
	# Cursed anvil: one more stat per copy, as Megabonk's anvil.
	if player != null and player.inventory != null:
		count += player.inventory.extra_upgrade_stats()
	for upgrade_stat in pool.slice(0, count):
		upgrade[upgrade_stat] = data.upgrade_value(upgrade_stat, rarity)
	return upgrade


func apply_upgrade(upgrade: Dictionary) -> void:
	for upgrade_stat: StringName in upgrade:
		bonuses[upgrade_stat] = bonuses.get(upgrade_stat, 0.0) + upgrade[upgrade_stat]
	level += 1
	_on_level_changed()


## Rebuilds what depends on the stats (bats, slashes) after a player-wide change such as extra projectiles.
func refresh() -> void:
	_on_level_changed()


func cooldown() -> float:
	return stat(&"cooldown") / (1.0 + player.attack_speed())


## Damage per hit after the player's damage multiplier and this weapon's rarity bonus.
func damage() -> float:
	return stat(&"damage") * player.damage_multiplier * player.item_damage_multiplier()


## Attack size after the player's area multiplier.
func area() -> float:
	return stat(&"area") * player.area_multiplier


func _physics_process(delta: float) -> void:
	if player == null or player.is_dead:
		return
	_cooldown_left -= delta
	if _cooldown_left <= 0.0:
		# With no target the weapon retries soon instead of waiting a full cooldown.
		_cooldown_left = cooldown() if _attack() else 0.1


## Performs one attack. Returns false when there was nothing to attack.
func _attack() -> bool:
	return false


func _on_setup() -> void:
	pass


func _on_level_changed() -> void:
	pass
