class_name CharacterSelect
extends Control
## Character selection screen: every character with its look, starting weapon and passive.
## Picking one remembers it (Progress.character) and emits `chosen`.

signal chosen(character: CharacterData)
signal closed

const CARD_SIZE := Vector2(250, 250)
const PORTRAIT_HEIGHT := 92.0
const MAX_WIDTH := 820.0

var _title: Label
var _scroll: ScrollContainer
var _grid: GridContainer
var _back_button: Button
## Animated portraits on screen: [TextureRect, SpriteFrames].
var _portraits: Array[Array] = []
var _time := 0.0


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.06, 0.85)
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

	_title = _label("Elige personaje", 38, Palette.GOLD)
	_title.add_theme_font_override("font", Palette.FONT_BOLD)
	box.add_child(_title)
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.follow_focus = true
	box.add_child(_scroll)
	_grid = GridContainer.new()
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.add_theme_constant_override("h_separation", 10)
	_grid.add_theme_constant_override("v_separation", 10)
	_scroll.add_child(_grid)

	_back_button = Button.new()
	_back_button.text = "Volver"
	_back_button.custom_minimum_size = Vector2(220, 56)
	_back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_back_button.pressed.connect(close)
	box.add_child(_back_button)


## Shows every character, starting on the last one chosen. `heading` replaces the title.
func open(heading := "Elige personaje") -> void:
	_title.text = heading
	_rebuild()
	visible = true


func close() -> void:
	if not visible:
		return
	Audio.play(&"click", 0.0)
	visible = false
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed(&"pause") or event.is_action_pressed(&"ui_cancel")):
		get_viewport().set_input_as_handled()
		close()


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta
	for entry in _portraits:
		var frames: SpriteFrames = entry[1]
		var count := frames.get_frame_count(&"walk")
		entry[0].texture = frames.get_frame_texture(&"walk", int(_time * frames.get_animation_speed(&"walk") * 0.6) % count)


func _rebuild() -> void:
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	_portraits.clear()
	var screen := get_viewport_rect().size
	var columns := clampi(int((minf(screen.x - 60.0, MAX_WIDTH) + 10.0) / (CARD_SIZE.x + 10.0)), 1, 3)
	_grid.columns = columns
	var rows := ceili(Characters.ALL.size() / float(columns))
	var width := columns * CARD_SIZE.x + (columns - 1) * 10.0
	_scroll.custom_minimum_size = Vector2(width + 12.0, minf(rows * (CARD_SIZE.y + 10.0), screen.y - 190.0))
	var focus: Button = null
	for character in Characters.ALL:
		var card := _card(character)
		_grid.add_child(card)
		if String(character.id) == Progress.character or focus == null:
			focus = card
	if focus != null:
		focus.grab_focus.call_deferred()


func _card(character: CharacterData) -> Button:
	var selected := String(character.id) == Progress.character
	var border := Palette.GOLD if selected else Palette.PURPLE_LIGHT
	var button := Button.new()
	button.custom_minimum_size = CARD_SIZE
	button.add_theme_stylebox_override("normal", Palette.box(Palette.NIGHT_LIGHT, border, 3, 2, 10.0))
	button.add_theme_stylebox_override("hover", Palette.box(Palette.NIGHT_LIGHT.lightened(0.08), Palette.GOLD, 3, 2, 10.0))
	button.add_theme_stylebox_override("focus", Palette.box(Palette.NIGHT_LIGHT.lightened(0.08), Palette.GOLD, 4, 2, 10.0))
	button.add_theme_stylebox_override("pressed", Palette.box(Palette.NIGHT_LIGHT.lightened(0.15), Palette.GOLD, 4, 2, 10.0))
	button.pressed.connect(_pick.bind(character))

	var content := VBoxContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 10)
	content.add_theme_constant_override("separation", 4)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(content)

	var portrait := TextureRect.new()
	portrait.texture = character.frames.get_frame_texture(&"idle", 0)
	portrait.custom_minimum_size = Vector2(0, PORTRAIT_HEIGHT)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(portrait)
	_portraits.append([portrait, character.frames])

	var name_label := _label(character.display_name, 28, Palette.GOLD if selected else Palette.BONE)
	name_label.add_theme_font_override("font", Palette.FONT_BOLD)
	content.add_child(name_label)

	var weapon_row := HBoxContainer.new()
	weapon_row.alignment = BoxContainer.ALIGNMENT_CENTER
	weapon_row.add_theme_constant_override("separation", 6)
	weapon_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var weapon_icon := TextureRect.new()
	weapon_icon.texture = character.starting_weapon.icon
	weapon_icon.custom_minimum_size = Vector2(26, 26)
	weapon_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	weapon_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	weapon_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	weapon_row.add_child(weapon_icon)
	weapon_row.add_child(_label(character.starting_weapon.display_name, 20, Palette.ORANGE))
	content.add_child(weapon_row)

	var bonus := _label(character.bonus_text, 18, Palette.GREEN)
	bonus.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(bonus)
	var description := _label(character.description, 16, Color(Palette.BONE, 0.7))
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(description)
	return button


func _pick(character: CharacterData) -> void:
	Audio.play(&"click", 0.0)
	Progress.set_character(String(character.id))
	visible = false
	chosen.emit(character)


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label
