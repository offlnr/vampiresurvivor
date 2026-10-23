class_name PowerUps
extends RefCounted
## Power-ups dropped by enemies: name, icon, drop weight and duration (0 = instant).

const TABLE := {
	&"heart": {name = "Corazón", icon = preload("res://art/placeholder/icon_heart.svg"), weight = 22.0, duration = 0.0},
	&"magnet": {name = "Imán", icon = preload("res://art/placeholder/icon_magnet.svg"), weight = 20.0, duration = 0.0},
	&"clock": {name = "Reloj", icon = preload("res://art/placeholder/powerups/clock.svg"), weight = 8.0, duration = 6.0},
	&"bomb": {name = "Bomba de calabaza", icon = preload("res://art/placeholder/powerups/bomb.svg"), weight = 8.0, duration = 0.0},
	&"broom": {name = "Escoba", icon = preload("res://art/placeholder/powerups/broom.svg"), weight = 14.0, duration = 10.0},
	&"rage": {name = "Furia", icon = preload("res://art/placeholder/powerups/rage.svg"), weight = 12.0, duration = 10.0},
	&"gold_rain": {name = "Lluvia de oro", icon = preload("res://art/placeholder/powerups/gold_rain.svg"), weight = 10.0, duration = 20.0},
	&"shield": {name = "Escudo", icon = preload("res://art/placeholder/powerups/shield_bubble.svg"), weight = 6.0, duration = 6.0},
	# Dropped only by the "Caramelo de calavera" item, never rolled.
	&"candy": {name = "Caramelo", icon = preload("res://art/placeholder/icon_candy.svg"), weight = 0.0, duration = 0.0},
	# Short boosts from items, shown in the HUD with their countdown; never rolled.
	&"coward": {name = "Capa del cobarde", icon = preload("res://art/placeholder/items/coward_cloak.svg"), weight = 0.0, duration = 0.0},
	&"shroud": {name = "Sudario fantasmal", icon = preload("res://art/placeholder/items/phantom_shroud.svg"), weight = 0.0, duration = 0.0},
}
## Chance that a normal enemy drops a power-up when it dies. Elites always drop one.
const DROP_CHANCE := 0.012
const HEART_HEAL := 0.3
## Share of max health healed by the candy dropped by the skull candy item.
const CANDY_HEAL := 0.1
const BOMB_ELITE_DAMAGE := 0.25


static func roll() -> StringName:
	var total := 0.0
	for kind in TABLE:
		total += TABLE[kind].weight
	var pick := randf() * total
	for kind in TABLE:
		pick -= TABLE[kind].weight
		if pick <= 0.0 and TABLE[kind].weight > 0.0:
			return kind
	return &"heart"


static func icon(kind: StringName) -> Texture2D:
	return TABLE[kind].icon


static func duration(kind: StringName) -> float:
	return TABLE[kind].duration
