extends PanelContainer
## Debug-only panel (F3 or a four-finger tap): performance numbers and shortcuts for testing.

var run: Node

var _touches := {}
var _refresh_left := 0.0

@onready var info: Label = $VBox/Info
@onready var buttons: HBoxContainer = $VBox/Buttons


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	visible = false
	_add_button("+1 nivel", func() -> void: run.debug_level_up())
	_add_button("+200 enemigos", func() -> void: run.enemy_manager.spawn_burst(200))
	_add_button("+1 min", func() -> void: run.debug_skip(60.0))
	_add_button("Atraer almas", func() -> void: run.pickups.attract_all())
	_add_button("Horda", func() -> void: run.enemy_manager.start_horde())
	_add_button("Cofre", func() -> void: run.debug_chest())
	_add_button("+100 oro", func() -> void: run.debug_gold(100))
	_add_button("Comerciante", func() -> void: run.merchants.spawn(Rarity.roll(run.player.luck)))
	_add_button("Power-up", func() -> void: run.debug_power_up())
	_add_button("Caldero", func() -> void: run.debug_cauldron())
	_add_button("+100 plata", func() -> void:
		Progress.silver += 100
		Progress.save_progress())


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F3:
		visible = not visible
	elif event is InputEventScreenTouch:
		if event.pressed:
			_touches[event.index] = true
			if _touches.size() >= 4:
				visible = not visible
				_touches.clear()
		else:
			_touches.erase(event.index)


func _process(delta: float) -> void:
	if not visible or run == null:
		return
	_refresh_left -= delta
	if _refresh_left > 0.0:
		return
	_refresh_left = 0.25
	var enemies: EnemyManager = run.enemy_manager
	info.text = "FPS %d   |   enemigos %d (pool %d)   |   almas %d (pool %d)   |   oleada %d   |   tiempo %ds" % [
		Engine.get_frames_per_second(),
		enemies.count(), enemies.pool_size(),
		run.pickups.count(), run.pickups.pool_size(),
		enemies.wave_table.index_at(run.elapsed) + 1,
		int(run.elapsed),
	]


func _add_button(text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 18)
	button.pressed.connect(action)
	buttons.add_child(button)
