extends Control
## Floating touch joystick: appears where the screen is touched and drives the move_* actions.

const RADIUS := 90.0
const KNOB_RADIUS := 36.0
const DEADZONE := 0.15

## Screen areas where a touch must not start the joystick (e.g. the pause button).
var blocked_rects: Callable = func() -> Array[Rect2]: return []

var _touch_index := -1
var _origin := Vector2.ZERO
var _knob := Vector2.ZERO


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1 and _can_start(event.position):
			_touch_index = event.index
			_origin = event.position
			_update_knob(event.position)
		elif not event.pressed and event.index == _touch_index:
			_reset()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_knob(event.position)


func _notification(what: int) -> void:
	# A finger lifted while paused never reaches us; drop the stick so the player doesn't drift.
	if what == NOTIFICATION_PAUSED:
		_reset()


func _can_start(pos: Vector2) -> bool:
	for rect: Rect2 in blocked_rects.call():
		if rect.has_point(pos):
			return false
	return true


func _update_knob(pos: Vector2) -> void:
	var offset := pos - _origin
	if offset.length() > RADIUS:
		# The base follows the finger so the player never has to come back to it.
		_origin = pos - offset.normalized() * RADIUS
		offset = pos - _origin
	_knob = _origin + offset
	var vector := offset / RADIUS
	_apply(vector if vector.length() >= DEADZONE else Vector2.ZERO)
	queue_redraw()


func _reset() -> void:
	_touch_index = -1
	_apply(Vector2.ZERO)
	queue_redraw()


func _apply(vector: Vector2) -> void:
	_set_action(&"move_right", maxf(vector.x, 0.0))
	_set_action(&"move_left", maxf(-vector.x, 0.0))
	_set_action(&"move_down", maxf(vector.y, 0.0))
	_set_action(&"move_up", maxf(-vector.y, 0.0))


func _set_action(action: StringName, strength: float) -> void:
	if strength > 0.0:
		Input.action_press(action, strength)
	else:
		Input.action_release(action)


func _draw() -> void:
	if _touch_index == -1:
		return
	var origin := _origin - global_position
	var knob := _knob - global_position
	draw_circle(origin, RADIUS, Color(Palette.NIGHT, 0.35))
	draw_arc(origin, RADIUS, 0.0, TAU, 48, Color(Palette.BONE, 0.5), 3.0, true)
	draw_circle(knob, KNOB_RADIUS, Color(Palette.ORANGE, 0.75))
	draw_arc(knob, KNOB_RADIUS, 0.0, TAU, 32, Color(Palette.INK, 0.8), 3.0, true)
