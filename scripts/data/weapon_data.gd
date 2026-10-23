class_name WeaponData
extends Resource
## A weapon: base stats plus the stats its upgrades can improve (Megabonk style).

## New patterns go at the end: weapon resources store the index.
enum Pattern { PROJECTILE, ORBIT, AURA, SWEEP, BOOMERANG, ZONE, CHAIN, TRAIL, VORTEX, SPREAD }

## Upgrade value multiplier per rarity, as in Megabonk (shared with scrolls).
const RARITY_FACTORS := Rarity.MULTIPLIERS
## Order in which upgrade stats are listed on a card.
const STAT_ORDER: Array[StringName] = [&"damage", &"amount", &"attack_speed", &"area", &"duration", &"speed", &"pierce"]

@export var id: StringName
@export var display_name := ""
@export var icon: Texture2D
@export var pattern := Pattern.PROJECTILE
@export var scene: PackedScene
@export_multiline var description := ""
## Names used in upgrade texts, e.g. "+1 calabaza", "+12 % de radio".
@export var amount_singular := "proyectil"
@export var amount_plural := "proyectiles"
@export var area_label := "tamaño"
@export var duration_label := "duración"
## How a pierce upgrade reads: "atraviesa a 1 enemigo más", "salta a 1 enemigo más".
@export var pierce_label := "atraviesa a"
## Maximum distance at which the weapon picks targets and its projectiles travel. 0 = no limit.
@export var attack_range := 0.0

@export_group("Base stats")
@export var damage := 10.0
## Seconds between attacks.
@export var cooldown := 1.0
@export var amount := 1
## Size of the attack in world units: projectile size, orbit radius or aura radius.
@export var area := 32.0
@export var duration := 1.0
@export var speed := 400.0
@export var pierce := 0

@export_group("Upgrades")
## Stats an upgrade can improve: amount and pierce (+N), and damage, attack_speed,
## area, duration and speed as a fraction of the base (0.1 = +10 %).
@export var upgrade_stats: Array[StringName] = []
## Common-rarity value of each stat in `upgrade_stats`, same order.
@export var upgrade_values: PackedFloat32Array


func upgrade_value(stat: StringName, rarity: int) -> float:
	var index := upgrade_stats.find(stat)
	if index == -1:
		return 0.0
	var value := upgrade_values[index] * RARITY_FACTORS[rarity]
	# Counts are whole: a "+1 projectile" gives +1 up to rare and +2 at epic and legendary.
	return float(roundi(value)) if is_count_stat(stat) else value


## Amount and pierce are whole numbers of projectiles and enemies.
static func is_count_stat(stat: StringName) -> bool:
	return stat == &"amount" or stat == &"pierce"


## Card text for an upgrade ({stat: value}), listing only gains.
func describe_upgrade(upgrade: Dictionary) -> String:
	var parts: PackedStringArray = []
	for stat in STAT_ORDER:
		if not upgrade.has(stat):
			continue
		var value: float = upgrade[stat]
		match stat:
			&"damage":
				parts.append("+%s de daño" % _percent(value))
			&"amount":
				parts.append("+%s %s" % [count_text(value), amount_singular if is_equal_approx(value, 1.0) else amount_plural])
			&"attack_speed":
				parts.append("+%s de velocidad de ataque" % _percent(value))
			&"area":
				parts.append("+%s de %s" % [_percent(value), area_label])
			&"duration":
				parts.append("+%s de %s" % [_percent(value), duration_label])
			&"speed":
				parts.append("+%s de velocidad de vuelo" % _percent(value))
			&"pierce":
				parts.append("%s %s enemigo%s más" % [pierce_label, count_text(value), "" if is_equal_approx(value, 1.0) else "s"])
	return ", ".join(parts) + "."


## A whole count: "1", "2".
static func count_text(value: float) -> String:
	return str(roundi(value))


## A number with at most one decimal, Spanish style: "12", "0,6".
static func decimal_text(value: float) -> String:
	return ("%.1f" % value).trim_suffix(".0").replace(".", ",")


static func _percent(fraction: float) -> String:
	return "%d %%" % roundi(fraction * 100.0)

