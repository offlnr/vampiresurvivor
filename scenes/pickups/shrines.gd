class_name Shrines
extends Node2D
## Structures scattered around the players, as in Megabonk:
## - power shrines: standing inside the circle charges one; once full, whoever charged it picks one
##   of three stat upgrades for their own character, without using a scroll slot;
## - magnet totems: standing on one for a moment pulls every soul and coin on the map.
## A used structure comes back somewhere else after a while. In co-op, either player can use them.

signal shrine_charged(shrine_position: Vector2, activator: Player)
signal magnet_used(shrine_position: Vector2, activator: Player)

enum Kind { POWER, MAGNET }

const GLOW := preload("res://art/placeholder/puff.svg")
const POWER_COLOR := Color("ffd25a")
const MAGNET_COLOR := Color("e0344a")
## Per kind: texture, how many are around at once, seconds before a used one comes back, seconds to
## stand on it, how close the player must be and the colour of its circle.
const SPECS := {
	Kind.POWER: {texture = preload("res://art/placeholder/shrine.svg"), count = 2, respawn = 50.0,
		charge_time = 4.0, reach = 95.0, color = POWER_COLOR, offset = -40.0},
	Kind.MAGNET: {texture = preload("res://art/placeholder/magnet_totem.svg"), count = 1, respawn = 70.0,
		charge_time = 1.0, reach = 55.0, color = MAGNET_COLOR, offset = -44.0},
}
const MIN_DISTANCE := 700.0
const MAX_DISTANCE := 1800.0
const RELOCATE_DISTANCE := 2800.0
const MIN_SPACING := 500.0
const SPOT_TRIES := 12
## A charge cools down at this share of its charging speed while nobody stands on it.
const COOL_DOWN := 0.35

var player: Player
## Every character that can use them: the player, plus the guest's in online co-op. Empty means just `player`.
var players: Array[Player] = []
var decorations: Decorations

var _shrines: Array[Shrine] = []
## Kind -> seconds left for each used structure before it comes back.
var _respawns := {Kind.POWER: [], Kind.MAGNET: []}
var _time := 0.0


func positions(kind: Kind) -> Array[Vector2]:
	var result: Array[Vector2] = []
	for shrine in _shrines:
		if shrine.kind == kind:
			result.append(shrine.position)
	return result


func _physics_process(delta: float) -> void:
	var alive: Array[Player] = []
	for p in players if not players.is_empty() else [player]:
		if p != null and not p.is_dead:
			alive.append(p)
	if alive.is_empty():
		return
	_time += delta
	for kind: Kind in SPECS:
		var timers: Array = _respawns[kind]
		for i in range(timers.size() - 1, -1, -1):
			timers[i] -= delta
			if timers[i] <= 0.0:
				timers.remove_at(i)
		while positions(kind).size() + timers.size() < SPECS[kind].count:
			_spawn(kind)
	for shrine in _shrines.duplicate():
		var spec: Dictionary = SPECS[shrine.kind]
		var nearest: Player = null
		var nearest_distance := INF
		for p in alive:
			var distance: float = shrine.position.distance_to(p.global_position)
			if distance < nearest_distance:
				nearest = p
				nearest_distance = distance
		if nearest_distance > RELOCATE_DISTANCE:
			shrine.position = _random_spot(alive)
			shrine.set_progress(0.0)
			continue
		shrine.animate(_time)
		if nearest_distance < spec.reach:
			shrine.set_progress(shrine.progress + delta / spec.charge_time)
			if shrine.progress >= 1.0:
				_use(shrine, nearest)
		elif shrine.progress > 0.0:
			shrine.set_progress(maxf(shrine.progress - delta * COOL_DOWN / spec.charge_time, 0.0))


func _use(shrine: Shrine, activator: Player) -> void:
	_shrines.erase(shrine)
	_respawns[shrine.kind].append(SPECS[shrine.kind].respawn)
	if shrine.kind == Kind.POWER:
		shrine_charged.emit(shrine.position, activator)
	else:
		magnet_used.emit(shrine.position, activator)
	var tween := shrine.create_tween()
	tween.tween_property(shrine, "scale", Vector2(1.3, 0.1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(shrine.queue_free)


func _spawn(kind: Kind) -> void:
	var alive: Array[Player] = []
	for p in players if not players.is_empty() else [player]:
		if p != null and not p.is_dead:
			alive.append(p)
	var shrine := Shrine.new(kind)
	shrine.position = _random_spot(alive)
	add_child(shrine)
	_shrines.append(shrine)


## A spot around one of the players, away from the other structures and outside solid props
## (or the last try, if the area is crowded).
func _random_spot(around: Array[Player]) -> Vector2:
	var anchor: Vector2 = around.pick_random().global_position if not around.is_empty() else player.global_position
	var spot := Vector2.ZERO
	for i in SPOT_TRIES:
		spot = anchor + Vector2.from_angle(randf() * TAU) * randf_range(MIN_DISTANCE, MAX_DISTANCE)
		var spaced := _shrines.all(func(other: Shrine) -> bool: return other.position.distance_to(spot) >= MIN_SPACING)
		if spaced and (decorations == null or decorations.is_free(spot, 60.0)):
			break
	return spot


## One structure: its sprite with a glow, and a circle on the ground that fills while it charges.
class Shrine extends Node2D:
	var kind: Kind
	var progress := 0.0
	var _sprite: Sprite2D
	var _glow: Sprite2D
	var _zone: Zone

	func _init(shrine_kind: Kind) -> void:
		kind = shrine_kind
		var spec: Dictionary = SPECS[kind]
		# The circle lies on the ground, under the characters that stand on it.
		_zone = Zone.new()
		_zone.radius = spec.reach
		_zone.color = spec.color
		_zone.z_index = -1
		add_child(_zone)
		_glow = Sprite2D.new()
		_glow.texture = GLOW
		_glow.modulate = Color(spec.color, 0.3)
		_glow.position.y = spec.offset
		add_child(_glow)
		_sprite = Sprite2D.new()
		_sprite.texture = spec.texture
		_sprite.offset.y = spec.offset
		add_child(_sprite)

	func animate(time: float) -> void:
		var phase := time * 2.5 + position.x * 0.01
		_glow.scale = Vector2.ONE * (1.4 + 0.15 * sin(phase) + progress * 0.8)
		_sprite.position.y = -3.0 * (0.5 + 0.5 * sin(phase)) if kind == Kind.POWER else 0.0

	func set_progress(value: float) -> void:
		progress = clampf(value, 0.0, 1.0)
		_zone.progress = progress
		_zone.queue_redraw()


## The ground circle (see NetDraw, so the online guest sees it too).
class Zone extends Node2D:
	var radius := 60.0
	var color := Color.WHITE
	var progress := 0.0

	func _draw() -> void:
		NetDraw.paint(self, draw_ops())

	func draw_ops() -> Array:
		var ops: Array = [
			[NetDraw.CIRCLE, Vector2.ZERO, radius, Color(color, 0.08 + 0.12 * progress)],
			[NetDraw.ARC, Vector2.ZERO, radius, 0.0, TAU, 48, Color(color, 0.45), 3.0],
		]
		if progress > 0.0:
			ops.append([NetDraw.ARC, Vector2.ZERO, radius, -PI / 2.0, -PI / 2.0 + TAU * progress, 48, color, 6.0])
		return ops
