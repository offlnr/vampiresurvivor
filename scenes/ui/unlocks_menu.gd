class_name UnlocksMenu
extends Control
## Main-menu screen to unlock weapons, scrolls and items with silver, as in Megabonk: each entry
## shows its challenge and progress, and can be bought once the challenge is met.

signal closed

const COIN_ICON := preload("res://art/placeholder/silver_coin.svg")
const SILVER := Color("c9cedb")
const MAX_WIDTH := 780.0
const ICON_SIZE := 52.0

var _silver_label: Label
var _scroll: ScrollContainer
var _list: VBoxContainer
var _back_button: Button


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

	var title := _label("Desbloqueos", 38, Palette.GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", Palette.FONT_BOLD)
	box.add_child(title)
	var silver_row := HBoxContainer.new()
	silver_row.alignment = BoxContainer.ALIGNMENT_CENTER
	var coin := TextureRect.new()
	coin.texture = COIN_ICON
	coin.custom_minimum_size = Vector2(26, 26)
	coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	silver_row.add_child(coin)
	_silver_label = _label("0", 26, SILVER)
	silver_row.add_child(_silver_label)
	box.add_child(silver_row)
	var hint := _label("Cumple el desafío y cómpralo con plata. Lo bloqueado no aparece en las partidas.", 18, Color(Palette.BONE, 0.75))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(hint)

	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.follow_focus = true
	box.add_child(_scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 6)
	_scroll.add_child(_list)

	_back_button = Button.new()
	_back_button.text = "Volver"
	_back_button.custom_minimum_size = Vector2(220, 56)
	_back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_back_button.pressed.connect(close)
	box.add_child(_back_button)


func open() -> void:
	_rebuild()
	visible = true
	_scroll.scroll_vertical = 0
	_back_button.grab_focus()


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


func _rebuild(focus_key := "") -> void:
	_silver_label.text = str(Progress.silver)
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	var screen := get_viewport_rect().size
	var width := minf(MAX_WIDTH, screen.x - 80.0)
	_scroll.custom_minimum_size = Vector2(width, minf(480.0, screen.y - 300.0))
	var focus_button: Button = null
	for section in Unlocks.SECTIONS:
		var header := _label(section.title, 26, Palette.ORANGE)
		header.add_theme_font_override("font", Palette.FONT_BOLD)
		_list.add_child(header)
		for e in Unlocks.ENTRIES:
			if e.key.begins_with(section.prefix):
				var button := _row(e, width)
				if e.key == focus_key:
					focus_button = button
	if focus_button != null:
		focus_button.grab_focus()


## One entry: [icon | name, challenge, progress | buy button]. Returns the button.
func _row(e: Dictionary, width: float) -> Button:
	var data: Resource = load(e.path)
	var owned: bool = Progress.unlocked.has(e.key)
	var done := Progress.quest_done(e)
	var row := PanelContainer.new()
	var border := Palette.GREEN if owned else (Palette.GOLD if done else Palette.PURPLE)
	row.add_theme_stylebox_override("panel", Palette.box(Color(Palette.NIGHT_LIGHT, 0.9), border, 2, 2, 8.0, false))
	_list.add_child(row)
	var content := HBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	row.add_child(content)

	var icon := TextureRect.new()
	icon.texture = data.icon
	icon.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	# Still-locked entries are shown as a dark silhouette until their challenge is met.
	icon.modulate = Color.WHITE if owned or done else Color(0.25, 0.22, 0.32)
	content.add_child(icon)

	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_theme_constant_override("separation", 0)
	content.add_child(text)
	text.add_child(_label(data.display_name, 22, Palette.BONE if owned or done else Color(Palette.BONE, 0.7)))
	var quest := _label(Unlocks.quest_text(e), 17, Color(Palette.BONE, 0.75))
	quest.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quest.custom_minimum_size.x = width - ICON_SIZE - 230.0
	text.add_child(quest)
	var status := "Desbloqueado" if owned else ("¡Desafío cumplido!" if done else Unlocks.progress_text(e, Progress.stat(e.stat)))
	text.add_child(_label(status, 17, Palette.GREEN if owned else (Palette.GOLD if done else Palette.PURPLE_LIGHT)))

	var button := Button.new()
	button.custom_minimum_size = Vector2(170, 52)
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if owned:
		button.text = "Tuyo"
		button.disabled = true
	else:
		button.text = "%d plata" % e.price
		button.disabled = not Progress.can_buy(e)
		button.tooltip_text = "Cumple el desafío primero" if not done else ("Te falta plata" if button.disabled else "Desbloquear")
	button.pressed.connect(_buy.bind(e.key))
	content.add_child(button)
	return button


func _buy(key: String) -> void:
	if Progress.buy(key):
		Audio.play(&"buy", 0.0)
	_rebuild(key)
	if get_viewport().gui_get_focus_owner() == null:
		_back_button.grab_focus()


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", 4)
	return label
