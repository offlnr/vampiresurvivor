extends Weapon
## Spectral lightning (Megabonk's lightning staff): bolts fall on enemies near the player and jump
## from enemy to enemy. `pierce` is the number of jumps, `area` how far a jump reaches.

const BOLT_COLOR := Color("b9f3ff")
const GLOW_COLOR := Color(0.42, 0.78, 1.0, 0.45)
const FADE_TIME := 0.22
## Bolts pick among this many of the nearest enemies, so they don't all hit the same one.
const TARGET_POOL := 12


func _attack() -> bool:
	var candidates := enemies.nearest(player.global_position, data.attack_range, TARGET_POOL)
	if candidates.is_empty():
		return false
	candidates.shuffle()
	var hit_damage := damage()
	var jumps := int(stat(&"pierce"))
	var reach := area()
	for i in int(stat(&"amount")):
		_strike(candidates[i % candidates.size()], hit_damage, jumps, reach)
	Audio.play(&"lightning", 0.12, -6.0)
	return true


## One bolt: falls from the sky on `first`, then jumps to the nearest enemy not hit yet.
func _strike(first: Enemy, hit_damage: float, jumps: int, reach: float) -> void:
	var points: Array[Vector2] = [first.position + Vector2(randf_range(-30, 30), -260)]
	var hit := {}
	var current := first
	while current != null:
		hit[current] = true
		points.append(current.position)
		var from := current.position
		enemies.damage(current, hit_damage, Vector2.ZERO, 0.0, EnemyManager.SOURCE_WEAPON, player)
		current = null
		if hit.size() > jumps:
			break
		for other in enemies.nearest(from, reach, 6):
			if not hit.has(other) and other.alive:
				current = other
				break
	_draw_bolt(points)


func _draw_bolt(points: Array[Vector2]) -> void:
	var jagged := PackedVector2Array()
	for i in points.size() - 1:
		var a := points[i]
		var b := points[i + 1]
		var normal := (b - a).orthogonal().normalized()
		for step in 4:
			var t := step / 4.0
			var offset := normal * randf_range(-10.0, 10.0) if step > 0 else Vector2.ZERO
			jagged.append(a.lerp(b, t) + offset)
	jagged.append(points.back())
	var glow := _line(jagged, 9.0, GLOW_COLOR)
	var core := _line(jagged, 3.0, BOLT_COLOR)
	var tween := glow.create_tween()
	tween.tween_property(glow, "modulate:a", 0.0, FADE_TIME)
	tween.parallel().tween_property(core, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(glow.queue_free)
	tween.tween_callback(core.queue_free)


func _line(points: PackedVector2Array, width: float, color: Color) -> Line2D:
	var line := Line2D.new()
	line.points = points
	line.width = width
	line.default_color = color
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.z_index = 8
	projectiles_root.add_child(line)
	return line
