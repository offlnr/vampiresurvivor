class_name StatsPanel
extends Control
## Full-screen overlay with the player's current stats and weapons, opened from the level-up and
## shop menus (like Megabonk's stats screen) so the player can check them before choosing.

signal closed

const TITLE_SIZE := 34
const SECTION_SIZE := 24
const ROW_SIZE := 19
const MAX_WIDTH := 620.0
## On wide screens the player's stats go in two pairs of columns, so they fit without scrolling.
const WIDE_SCREEN := 1000.0
const WIDE_WIDTH := 900.0

var _scroll: ScrollContainer
var _content: VBoxContainer
var _close_button: Button


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false

	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.06, 0.8)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)

	var title := Label.new()
	title.text = "Estadísticas"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", TITLE_SIZE)
	title.add_theme_color_override("font_color", Palette.GOLD)
	box.add_child(title)

	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(_scroll)
	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 4)
	_scroll.add_child(_content)

	_close_button = Button.new()
	_close_button.text = "Volver"
	_close_button.custom_minimum_size = Vector2(200, 52)
	_close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_close_button.pressed.connect(close)
	# Keyboard and gamepad focus stays on "Volver", so no card behind the panel can be picked.
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		_close_button.set_focus_neighbor(side, ^".")
	_close_button.focus_next = ^"."
	_close_button.focus_previous = ^"."
	box.add_child(_close_button)


## Shows the sections from `run.stats_sections()`: [{title, rows = [[name, value], ...]}].
func open(sections: Array[Dictionary]) -> void:
	for child in _content.get_children():
		_content.remove_child(child)
		child.queue_free()
	var wide := get_viewport_rect().size.x >= WIDE_SCREEN
	for section in sections:
		if section.rows.is_empty():
			continue
		var header := _label(section.title, SECTION_SIZE, Palette.ORANGE)
		header.add_theme_font_override("font", Palette.FONT_BOLD)
		_content.add_child(header)
		var grid := GridContainer.new()
		# Weapon rows are long, so they always take a full line.
		grid.columns = 4 if wide and section.get("compact", false) else 2
		grid.add_theme_constant_override("h_separation", 24)
		grid.add_theme_constant_override("v_separation", 2)
		_content.add_child(grid)
		for row: Array in section.rows:
			var name_label := _label(row[0], ROW_SIZE, Palette.BONE)
			name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			grid.add_child(name_label)
			var value_label := _label(row[1], ROW_SIZE, Palette.GOLD)
			value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			value_label.custom_minimum_size.x = 90.0
			grid.add_child(value_label)
	_fit_to_screen()
	visible = true
	_scroll.scroll_vertical = 0
	_close_button.grab_focus()


func close() -> void:
	if not visible:
		return
	Audio.play(&"click", 0.0)
	visible = false
	closed.emit()


## Up and down scroll the list (focus never leaves "Volver").
func _input(event: InputEvent) -> void:
	if not visible:
		return
	var step := 0
	if event.is_action_pressed(&"ui_down", true) or event.is_action_pressed(&"move_down", true):
		step = 1
	elif event.is_action_pressed(&"ui_up", true) or event.is_action_pressed(&"move_up", true):
		step = -1
	if step != 0:
		_scroll.scroll_vertical += step * 60
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed(&"pause") or event.is_action_pressed(&"ui_cancel")):
		get_viewport().set_input_as_handled()
		close()


func _fit_to_screen() -> void:
	var screen := get_viewport_rect().size
	var width := WIDE_WIDTH if screen.x >= WIDE_SCREEN else MAX_WIDTH
	_scroll.custom_minimum_size = Vector2(minf(width, screen.x - 80.0), minf(520.0, screen.y - 220.0))


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", 4)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	return label
