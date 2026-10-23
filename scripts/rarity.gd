class_name Rarity
extends RefCounted
## Upgrade rarities: colour, name, base weight and effect multiplier.

enum Tier { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

const NAMES: Array[String] = ["Común", "Poco común", "Rara", "Épica", "Legendaria"]
const COLORS: Array[Color] = [Color("a8a3b3"), Color("5cc24a"), Color("3d8bff"), Color("b05cff"), Color("ffc93d")]
const BASE_WEIGHTS: Array[float] = [60.0, 25.0, 10.0, 4.0, 1.0]
## Effect multiplier of every upgrade (weapons, scrolls) by rarity, as in Megabonk.
const MULTIPLIERS: Array[float] = [1.0, 1.2, 1.4, 1.6, 2.0]
## Megabonk's luck curve: each tier below legendary loses weight by this factor per step, raised to the luck bonus.
const LUCK_STEP := 1.5
const LUCK_SCALE := 1.5


## Megabonk's luck bonus: grows with the logarithm of luck, so each extra point helps less.
static func luck_bonus(luck: float) -> float:
	return log(maxf(luck, 0.0) + 1.0) * LUCK_SCALE


## Rolls a tier, as in Megabonk: weight = base × 1.5^(−steps below legendary × luck bonus),
## so luck shrinks the low tiers (common the most) and never touches legendary.
static func roll(luck: float, minimum := Tier.COMMON) -> int:
	var weights: Array[float] = []
	var total := 0.0
	var bonus := luck_bonus(luck)
	var top := Tier.size() - 1
	for tier in Tier.size():
		var weight := 0.0
		if tier >= minimum:
			weight = BASE_WEIGHTS[tier] * pow(LUCK_STEP, -(top - tier) * bonus)
		weights.append(weight)
		total += weight
	var pick := randf() * total
	for tier in Tier.size():
		pick -= weights[tier]
		if pick <= 0.0 and weights[tier] > 0.0:
			return tier
	return minimum


static func color(tier: int) -> Color:
	return COLORS[tier]


static func name_of(tier: int) -> String:
	return NAMES[tier]


static func multiplier(tier: int) -> float:
	return MULTIPLIERS[tier]
