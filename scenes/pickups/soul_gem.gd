class_name SoulGem
extends Node2D
## A soul dropped by an enemy. Its value sets its colour and size.

var value := 1
var attracted := false
var fly_speed := 0.0

var _time := 0.0

@onready var sprite: Sprite2D = $Sprite


func setup(xp_value: int) -> void:
	attracted = false
	fly_speed = 0.0
	_time = randf() * TAU
	set_value(xp_value)


func set_value(xp_value: int) -> void:
	value = xp_value
	# Like Megabonk's gems: 1 (common), 10 and 50+ (rarer, from merged souls and strong enemies).
	if value >= 50:
		sprite.modulate = Palette.ORANGE
		scale = Vector2.ONE * 1.5
	elif value >= 10:
		sprite.modulate = Palette.PURPLE_LIGHT
		scale = Vector2.ONE * 1.2
	else:
		sprite.modulate = Palette.GREEN
		scale = Vector2.ONE * 0.9


func animate(delta: float) -> void:
	_time += delta * 3.0
	sprite.position.y = sin(_time) * 3.0
	sprite.rotation = sin(_time * 0.5) * 0.1
