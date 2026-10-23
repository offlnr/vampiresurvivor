extends Weapon
## Ember trail (Megabonk's flamewalker): while the player walks, burning embers are left behind
## that damage whoever steps on them. Extra amount drops more embers side by side.

const TICK := 0.4
## Embers are only dropped after moving at least this far since the last drop.
const MIN_STEP := 10.0
const EMBER_COLOR := Color("ff7a1a")
const CORE_COLOR := Color("ffd25a")
## The crackle plays at most this often: embers drop every 0.3 s and a sound each time would tire.
const CRACKLE_INTERVAL := 1.4

var _layer: EmberLayer
var _last_drop := Vector2.INF
var _crackle_left := 0.0


func _on_setup() -> void:
	_layer = EmberLayer.new()
	_layer.weapon = self
	_layer.z_index = -1
	projectiles_root.add_child(_layer)


func _exit_tree() -> void:
	if is_instance_valid(_layer):
		_layer.queue_free()


func _process(delta: float) -> void:
	_crackle_left -= delta


func _attack() -> bool:
	var pos := player.global_position
	if _last_drop != Vector2.INF and pos.distance_to(_last_drop) < MIN_STEP:
		return true
	_last_drop = pos
	var amount := int(stat(&"amount"))
	var side := player.last_move_direction.orthogonal()
	var radius := area()
	for i in amount:
		var offset := side * (i - (amount - 1) / 2.0) * radius * 1.3
		_layer.add(pos + offset, radius, stat(&"duration"))
	if _crackle_left <= 0.0:
		_crackle_left = CRACKLE_INTERVAL * randf_range(0.8, 1.2)
		Audio.play(&"embers", 0.15, -12.0)
	return true


class EmberLayer:
	extends Node2D
	## Draws and ticks every ember of one trail weapon in world space.

	var weapon: Weapon
	## Each ember: [position, radius, life left, total life, tick left].
	var embers: Array = []
	var _time := 0.0

	func add(pos: Vector2, radius: float, life: float) -> void:
		embers.append([pos, radius, life, life, randf() * TICK])

	func _physics_process(delta: float) -> void:
		_time += delta
		if embers.is_empty():
			return
		var hit_damage := weapon.damage()
		for i in range(embers.size() - 1, -1, -1):
			var ember: Array = embers[i]
			ember[2] -= delta
			if ember[2] <= 0.0:
				embers[i] = embers.back()
				embers.pop_back()
				continue
			ember[4] -= delta
			if ember[4] <= 0.0:
				ember[4] = TICK
				for enemy in weapon.enemies.in_radius(ember[0], ember[1]):
					weapon.enemies.damage(enemy, hit_damage)
		queue_redraw()

	func _draw() -> void:
		for ember: Array in embers:
			var fade := clampf(ember[2] / minf(ember[3], 0.6), 0.0, 1.0)
			var flicker := 1.0 + 0.08 * sin(_time * 12.0 + ember[0].x * 0.1)
			draw_circle(ember[0], ember[1] * flicker, Color(EMBER_COLOR, 0.35 * fade))
			draw_circle(ember[0], ember[1] * 0.55 * flicker, Color(EMBER_COLOR, 0.6 * fade))
			draw_circle(ember[0], ember[1] * 0.25, Color(CORE_COLOR, 0.8 * fade))
