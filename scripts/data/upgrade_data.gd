class_name UpgradeData
extends Resource
## A scroll (like Megabonk's tomes): one stat, in percent, a flat amount or a whole count, with no maximum level.

## New stats go at the end: scroll resources store the index.
enum Stat {
	MAX_HEALTH, MOVE_SPEED, PICKUP_RADIUS, ATTACK_SPEED, DAMAGE, LUCK, LIFESTEAL, ARMOR, AREA, XP, AMOUNT,
	REGEN, SHIELD, EVASION, THORNS, CRIT, PROJECTILE_SPEED, DURATION, KNOCKBACK, GOLD, CURSE, CHAOS, SILVER,
}

@export var id: StringName
@export var display_name := ""
@export var icon: Texture2D
## Text shown on the card; "{value}" is replaced by the effect after applying rarity.
@export_multiline var description := ""
@export var stat := Stat.MAX_HEALTH
## Effect of one common pick, as a fraction (0.1 = 10 %), a flat amount, or a whole number for counts.
@export var amount_per_level := 0.1
## False for flat amounts (health per second, shield points, thorns damage), shown as they are.
@export var percent := true


## Counts (extra projectiles) are whole numbers.
func is_count() -> bool:
	return stat == Stat.AMOUNT


## Effect of one pick of this rarity: the common value times the rarity multiplier, as in Megabonk.
## Counts are rounded to whole projectiles: +1 up to rare, +2 at epic and legendary.
func roll_amount(rarity: int) -> float:
	var value := amount_per_level * Rarity.multiplier(rarity)
	return float(roundi(value)) if is_count() else value


func describe(amount: float) -> String:
	return description.replace("{value}", value_text(amount))


## The effect as shown to the player: "1", "12", "0,6".
func value_text(amount: float) -> String:
	if is_count():
		return str(roundi(amount))
	return WeaponData.decimal_text(amount * 100.0 if percent else amount)
