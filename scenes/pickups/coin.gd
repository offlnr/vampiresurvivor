class_name Coin
extends Sprite2D
## A gold coin on the ground. Attracted and collected like souls.

const TEXTURE := preload("res://art/placeholder/coin.svg")

var attracted := false
var fly_speed := 0.0
var _time := 0.0


func _init() -> void:
	texture = TEXTURE
	z_index = 1


func setup() -> void:
	attracted = false
	fly_speed = 0.0
	_time = randf() * TAU


func animate(delta: float) -> void:
	_time += delta * 5.0
	# A flat spin, like a coin turning on the spot.
	scale.x = 0.25 + 0.75 * absf(cos(_time))
