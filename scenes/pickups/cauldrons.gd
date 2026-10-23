class_name Cauldrons
extends Node2D
## Cursed cauldrons scattered around the player. Standing on one for a moment brews it (in co-op,
## either player can): the run gets harder and the players earn more experience and gold.

signal brewed(position: Vector2)

const TEXTURE := preload("res://art/placeholder/cauldron.svg")
const GLOW := preload("res://art/placeholder/puff.svg")
const COUNT := 6
const MIN_DISTANCE := 600.0
const MAX_DISTANCE := 1700.0
const RELOCATE_DISTANCE := 2600.0
## Cauldrons keep at least this far apart, so they spread over the map instead of clumping.
const MIN_SPACING := 450.0
const SPOT_TRIES := 12
const REACH := 46.0
## Seconds the player must stand on a cauldron, so walking past one doesn't brew it by accident.
const BREW_TIME := 1.5

var player: Player
## Every character that can brew: the player, plus the guest's in online co-op. Empty means just `player`.
var players: Array[Player] = []
var decorations: Decorations

var _cauldrons: Array[Cauldron] = []
var _time := 0.0


func positions() -> Array[Vector2]:
	var result: Array[Vector2] = []
	for cauldron in _cauldrons:
		result.append(cauldron.position)
	return result


func _physics_process(delta: float) -> void:
	var alive: Array[Player] = []
	for p in players if not players.is_empty() else [player]:
		if p != null and not p.is_dead:
			alive.append(p)
	if alive.is_empty():
		return
	_time += delta
	while _cauldrons.size() < COUNT:
		_spawn()
	for cauldron in _cauldrons.duplicate():
		var nearest := INF
		for p in alive:
			nearest = minf(nearest, cauldron.position.distance_to(p.global_position))
		if nearest > RELOCATE_DISTANCE:
			cauldron.position = _random_spot()
			cauldron.set_progress(0.0)
			continue
		cauldron.animate(_time)
		if nearest < REACH:
			cauldron.set_progress(cauldron.progress + delta / BREW_TIME)
			if cauldron.progress >= 1.0:
				_brew(cauldron)
		elif cauldron.progress > 0.0:
			# The brew cools down if the player steps away.
			cauldron.set_progress(maxf(cauldron.progress - delta / BREW_TIME, 0.0))


func _brew(cauldron: Cauldron) -> void:
	_cauldrons.erase(cauldron)
	brewed.emit(cauldron.position)
	var tween := cauldron.create_tween()
	tween.tween_property(cauldron, "scale", Vector2(1.3, 0.1), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(cauldron.queue_free)


func _spawn() -> void:
	var cauldron := Cauldron.new()
	cauldron.position = _random_spot()
	cauldron.z_index = 2
	add_child(cauldron)
	_cauldrons.append(cauldron)


## A spot around the player away from the other cauldrons and outside solid props
## (or the last try, if the area is crowded).
func _random_spot() -> Vector2:
	var spot := Vector2.ZERO
	for i in SPOT_TRIES:
		spot = player.global_position + Vector2.from_angle(randf() * TAU) * randf_range(MIN_DISTANCE, MAX_DISTANCE)
		var spaced := _cauldrons.all(func(other: Cauldron) -> bool: return other.position.distance_to(spot) >= MIN_SPACING)
		if spaced and (decorations == null or decorations.is_free(spot, REACH)):
			break
	return spot


## One cauldron: bubbling sprite, green glow and a ring that fills while the player brews it.
class Cauldron extends Node2D:
	var progress := 0.0
	var _sprite: Sprite2D
	var _glow: Sprite2D

	func _init() -> void:
		_glow = Sprite2D.new()
		_glow.texture = GLOW
		_glow.modulate = Color(Palette.GREEN, 0.35)
		_glow.scale = Vector2.ONE * 1.6
		add_child(_glow)
		_sprite = Sprite2D.new()
		_sprite.texture = TEXTURE
		_sprite.offset.y = -20.0
		add_child(_sprite)

	func animate(time: float) -> void:
		var phase := time * 3.0 + position.x * 0.01
		_sprite.scale = Vector2(1.0 + 0.03 * sin(phase * 2.0), 1.0 - 0.03 * sin(phase * 2.0))
		_glow.scale = Vector2.ONE * (1.6 + 0.15 * sin(phase) + progress * 0.6)

	func set_progress(value: float) -> void:
		progress = clampf(value, 0.0, 1.0)
		queue_redraw()

	func _draw() -> void:
		NetDraw.paint(self, draw_ops())

	func draw_ops() -> Array:
		if progress <= 0.0:
			return []
		return [
			[NetDraw.ARC, Vector2(0, -20), 42.0, 0.0, TAU, 40, Color(Palette.INK, 0.7), 8.0],
			[NetDraw.ARC, Vector2(0, -20), 42.0, -PI / 2.0, -PI / 2.0 + TAU * progress, 40, Palette.GREEN, 5.0],
		]
