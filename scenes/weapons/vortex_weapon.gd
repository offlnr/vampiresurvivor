extends Weapon
## Soul vortex (Megabonk's black hole): opens on an enemy near the player, pulls the enemies
## around it towards its centre and damages them until it closes.

const TARGET_POOL := 10


func _attack() -> bool:
	var candidates := enemies.nearest(player.global_position, data.attack_range, TARGET_POOL)
	if candidates.is_empty():
		return false
	candidates.shuffle()
	for i in int(stat(&"amount")):
		var vortex := Vortex.new()
		projectiles_root.add_child(vortex)
		vortex.open(self, candidates[i % candidates.size()].position + Vector2(randf_range(-20, 20), randf_range(-20, 20)))
	Audio.play(&"vortex", 0.1, -5.0)
	return true


class Vortex:
	extends Node2D

	const TICK := 0.45
	## World units per second enemies are dragged towards the centre.
	const PULL_SPEED := 150.0
	const OPEN_TIME := 0.2
	const COLOR := Color("6b2fa8")
	const RIM := Color("a66be0")

	var weapon: Weapon
	var radius := 90.0
	var life := 2.0
	var _total := 2.0
	var _tick_left := 0.0
	var _time := 0.0

	func open(owner_weapon: Weapon, pos: Vector2) -> void:
		weapon = owner_weapon
		position = pos
		radius = weapon.area()
		life = weapon.stat(&"duration")
		_total = life
		z_index = -1

	func _physics_process(delta: float) -> void:
		_time += delta
		life -= delta
		if life <= 0.0:
			queue_free()
			return
		for enemy in weapon.enemies.in_radius(position, radius):
			if enemy.is_elite or enemy.data.knockback_immune or enemy.fixed_velocity != Vector2.ZERO:
				continue
			var to_center := position - enemy.position
			var distance := to_center.length()
			if distance > 4.0:
				enemy.position += to_center / distance * minf(PULL_SPEED * delta, distance)
		_tick_left -= delta
		if _tick_left <= 0.0:
			_tick_left = TICK
			var hit_damage := weapon.damage()
			for enemy in weapon.enemies.in_radius(position, radius):
				weapon.enemies.damage(enemy, hit_damage, Vector2.ZERO, 0.0, EnemyManager.SOURCE_WEAPON, weapon.player)
		queue_redraw()

	func _draw() -> void:
		NetDraw.paint(self, draw_ops())

	func draw_ops() -> Array:
		var grow := clampf(_time / OPEN_TIME, 0.0, 1.0) * clampf(life / OPEN_TIME, 0.0, 1.0)
		var r := radius * grow
		var ops: Array = [
			[NetDraw.CIRCLE, Vector2.ZERO, r, Color(COLOR, 0.28)],
			[NetDraw.CIRCLE, Vector2.ZERO, r * 0.35, Color(Palette.INK, 0.8)],
		]
		for arm in 4:
			var start := _time * 4.0 + TAU * arm / 4.0
			ops.append([NetDraw.ARC, Vector2.ZERO, r * 0.7, start, start + 1.4, 12, Color(RIM, 0.75), 3.0])
			ops.append([NetDraw.ARC, Vector2.ZERO, r * 0.45, -start, -start + 1.1, 10, Color(RIM, 0.55), 2.0])
		ops.append([NetDraw.ARC, Vector2.ZERO, r, 0.0, TAU, 40, Color(RIM, 0.5), 2.0])
		return ops
