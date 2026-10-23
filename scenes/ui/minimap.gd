extends Control
## Round minimap centred on the player: merchant, chests, cauldrons, power-ups and elites. North is up.

## World units from the centre to the edge of the minimap.
const WORLD_RADIUS := 1600.0
const REFRESH := 0.1

var run: Node

var _refresh_left := 0.0


func _process(delta: float) -> void:
	_refresh_left -= delta
	if _refresh_left <= 0.0:
		_refresh_left = REFRESH
		queue_redraw()


func _draw() -> void:
	var radius := minf(size.x, size.y) / 2.0
	var center := size / 2.0
	draw_circle(center, radius, Color(Palette.NIGHT, 0.72))
	draw_circle(center, radius * 0.5, Color(Palette.PURPLE, 0.12))
	draw_arc(center, radius - 1.5, 0.0, TAU, 48, Color(Palette.PURPLE_LIGHT, 0.8), 3.0, true)
	if run == null or not is_instance_valid(run):
		return
	var origin: Vector2 = run.player.global_position
	var scale := (radius - 8.0) / WORLD_RADIUS

	for pos: Vector2 in run.pickups.power_up_positions():
		_mark(center, radius, (pos - origin) * scale, Palette.BONE, 3.5, false)
	for pos: Vector2 in run.map_chests.positions():
		_mark(center, radius, (pos - origin) * scale, Color("b87333"), 4.5, true)
	for pos: Vector2 in run.cauldrons.positions():
		_mark(center, radius, (pos - origin) * scale, Palette.GREEN, 5.0, false)
	for pos: Vector2 in run.pickups.chest_positions():
		_mark(center, radius, (pos - origin) * scale, Palette.GOLD, 5.0, true)
	for enemy in run.enemy_manager.active():
		if enemy.is_elite and enemy.alive:
			_mark(center, radius, (enemy.position - origin) * scale, Palette.RED, 5.5, false)
	var merchant: Merchant = run.merchants.merchant
	if merchant != null and is_instance_valid(merchant):
		var color := Rarity.color(merchant.rarity)
		_mark(center, radius, (merchant.position - origin) * scale, color, 7.0, true)
	# The player: an orange arrow pointing where they last moved.
	var heading: Vector2 = run.player.last_move_direction
	var tip := center + heading * 8.0
	var side := heading.orthogonal() * 5.0
	draw_colored_polygon(PackedVector2Array([tip, center - heading * 5.0 + side, center - heading * 5.0 - side]), Palette.ORANGE)


## Draws a mark, or an arrow on the rim when it is beyond the minimap radius.
func _mark(center: Vector2, radius: float, offset: Vector2, color: Color, dot: float, square: bool) -> void:
	var limit := radius - 10.0
	if offset.length() > limit:
		var direction := offset.normalized()
		var tip := center + direction * (radius - 3.0)
		var back := center + direction * (radius - 15.0)
		var side := direction.orthogonal() * 7.0
		draw_colored_polygon(PackedVector2Array([tip, back + side, back - side]), color)
		return
	var pos := center + offset
	if square:
		draw_rect(Rect2(pos - Vector2(dot, dot), Vector2(dot, dot) * 2.0), color)
		draw_rect(Rect2(pos - Vector2(dot, dot), Vector2(dot, dot) * 2.0), Palette.INK, false, 1.5)
	else:
		draw_circle(pos, dot, color)
