class_name MapChests
extends Node2D
## Paid chests scattered around the player. Touching one asks the run to buy it.

signal chest_touched(chest: Node2D)

const TEXTURE := preload("res://art/placeholder/chest_paid.svg")
const COIN := preload("res://art/placeholder/coin.svg")
const COUNT := 5
const MIN_DISTANCE := 700.0
const MAX_DISTANCE := 1500.0
const RELOCATE_DISTANCE := 2500.0
const REACH := 40.0
## The first chests show up once the player has had time to collect some gold.
const FIRST_TIME := 20.0

var player: Player
var decorations: Decorations
var price := 25
var run_time := 0.0

var _chests: Array[Node2D] = []
## Chests the player is standing on, so a chest he can't afford isn't asked for every frame.
var _touching := {}
var _time := 0.0


func positions() -> Array[Vector2]:
	var result: Array[Vector2] = []
	for chest in _chests:
		result.append(chest.position)
	return result


func _physics_process(delta: float) -> void:
	if player == null or player.is_dead or run_time < FIRST_TIME:
		return
	_time += delta
	while _chests.size() < COUNT:
		_spawn()
	var target := player.global_position
	for chest: Node2D in _chests.duplicate():
		var label: Label = chest.get_node("Price")
		label.text = str(price)
		if chest.position.distance_to(target) > RELOCATE_DISTANCE:
			chest.position = _random_spot()
			continue
		chest.get_node("Sprite").offset.y = sin(_time * 3.0 + chest.position.x) * 3.0
		var touching: bool = chest.position.distance_to(target) < REACH
		if touching and not _touching.has(chest):
			_touching[chest] = true
			chest_touched.emit(chest)
		elif not touching:
			_touching.erase(chest)


func open(chest: Node2D) -> void:
	_chests.erase(chest)
	_touching.erase(chest)
	var tween := chest.create_tween()
	tween.tween_property(chest, "scale", Vector2(1.4, 0.2), 0.2)
	tween.tween_callback(chest.queue_free)


## Flashes the price in red: the player can't afford it.
func show_unaffordable(chest: Node2D) -> void:
	var label: Label = chest.get_node("Price")
	label.add_theme_color_override("font_color", Palette.RED)
	var tween := chest.create_tween()
	tween.tween_property(chest, "rotation", 0.12, 0.05)
	tween.tween_property(chest, "rotation", -0.12, 0.1)
	tween.tween_property(chest, "rotation", 0.0, 0.05)
	tween.tween_interval(1.2)
	tween.tween_callback(func() -> void: label.add_theme_color_override("font_color", Palette.GOLD))
	Audio.play(&"click", 0.0)


func _spawn() -> void:
	var chest := Node2D.new()
	chest.position = _random_spot()
	chest.z_index = 2
	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture = TEXTURE
	chest.add_child(sprite)
	var coin := Sprite2D.new()
	coin.texture = COIN
	coin.position = Vector2(-16, -40)
	chest.add_child(coin)
	var label := Label.new()
	label.name = "Price"
	label.position = Vector2(-4, -54)
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Palette.GOLD)
	chest.add_child(label)
	add_child(chest)
	_chests.append(chest)


## A spot around the player that is not inside a crypt, tree or other solid prop.
func _random_spot() -> Vector2:
	var spot := Vector2.ZERO
	for i in 12:
		spot = player.global_position + Vector2.from_angle(randf() * TAU) * randf_range(MIN_DISTANCE, MAX_DISTANCE)
		if decorations == null or decorations.is_free(spot, REACH):
			break
	return spot
