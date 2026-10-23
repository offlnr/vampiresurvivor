class_name ItemData
extends Resource
## An item bought from the merchant. Copies stack: each copy adds `value` to the effect.

enum Effect {
	POISON_ON_HIT, CANDY_ON_KILL, FREEZE_ON_HIT, GOLD_GAIN,
	VOODOO, MOVE_SPEED, HEAL_ON_KILL, CRIT,
	ECHO, POISON_CLOUD, MIRROR,
	LOW_HP_DAMAGE, SOUL_DAMAGE,
	EXECUTE, SOUL_HARVEST,
	ATTACK_SPEED, AUTO_MAGNET,
	# Stats added straight to the player when bought.
	LUCK, XP_GAIN, MAX_HP, REGEN, DAMAGE, EVASION, EXTRA_PROJECTILE, HOLY, LUCK_EVASION, PICKUP_RADIUS,
	# Extra damage on some hits.
	FULL_HP_DAMAGE, ELITE_DAMAGE, CLOSE_DAMAGE, BONK, MEGACRIT, CRIT_HEAL,
	# Damage that grows during the run.
	IDLE_DAMAGE, CHEST_DAMAGE, KILL_DAMAGE,
	# Movement, dodging and standing still.
	IDLE_HEAL, COWARD, DODGE_FRENZY, MOVING_ATTACK_SPEED,
	# When hurt.
	GOLD_ON_HURT, SHOCK_ON_HURT, POISON_ON_HURT, LAST_STAND,
	# On hit.
	EXPLODE_ON_HIT, LIGHTNING_ON_HIT, BURN_ON_HIT,
	# Others.
	FREE_CHEST, BELL, ANVIL,
}

@export var id: StringName
@export var display_name := ""
@export var icon: Texture2D
@export var rarity := Rarity.Tier.COMMON
@export var effect := Effect.POISON_ON_HIT
## Effect of one copy. A chance or fraction (0.15 = 15 %) unless `percent` is false.
@export var value := 0.1
@export var percent := true
## Text shown in the shop; "{value}" is replaced by the effect of one copy.
@export_multiline var description := ""


func describe() -> String:
	var shown := value * 100.0 if percent else value
	return description.replace("{value}", ("%.1f" % shown).trim_suffix(".0").replace(".", ","))
