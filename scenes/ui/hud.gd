extends Control
## In-run HUD: health, experience and level, time, kills and equipped weapons.

signal pause_pressed

const EDGE_MARGIN := 16
const CAULDRON_ICON := preload("res://art/placeholder/cauldron.svg")

@onready var margin: MarginContainer = $Margin
@onready var xp_bar: ProgressBar = $Margin/Layout/XPBar
@onready var level_label: Label = $Margin/Layout/XPBar/LevelLabel
@onready var health_bar: ProgressBar = $Margin/Layout/TopLeft/HealthRow/HealthBar
@onready var weapon_icons: HBoxContainer = $Margin/Layout/TopLeft/WeaponIcons
@onready var passive_icons: HBoxContainer = $Margin/Layout/TopLeft/PassiveIcons
@onready var buff_icons: HBoxContainer = $Margin/Layout/TopLeft/BuffIcons
@onready var time_label: Label = $Margin/Layout/TimeBadge/TimeLabel
@onready var minimap: Control = $Margin/Layout/TopRight/Minimap
@onready var gold_label: Label = $Margin/Layout/TopRight/Stats/GoldLabel
@onready var kills_label: Label = $Margin/Layout/TopRight/Stats/KillsLabel
@onready var pause_button: Button = $Margin/Layout/TopRight/PauseButton
## Wraps into more rows (growing upwards) when the player owns many different items.
@onready var item_icons: HFlowContainer = $Margin/Layout/ItemIcons
@onready var banner: Label = $Banner
@onready var _health_text: Label = $Margin/Layout/TopLeft/HealthRow/HealthBar/HealthText

var _shown_buffs := {}
var _difficulty_label: Label


func _ready() -> void:
	var health_styles := Palette.bar(Palette.RED)
	health_bar.add_theme_stylebox_override("background", health_styles[0])
	health_bar.add_theme_stylebox_override("fill", health_styles[1])
	_decorate()
	pause_button.pressed.connect(pause_pressed.emit)
	Settings.input_mode_changed.connect(_on_input_mode_changed)
	_on_input_mode_changed(Settings.touch_mode)
	get_viewport().size_changed.connect(_apply_safe_area)
	_apply_safe_area()
	banner.visible = false


func show_horde_warning(title: String) -> void:
	_show_banner("¡Se acerca una horda!\n%s" % title, Palette.RED, 2.8)


func show_merchant(rarity: int) -> void:
	_show_banner("¡Ha llegado un comerciante!\n%s" % Rarity.name_of(rarity), Rarity.color(rarity), 2.2)


func set_gold(gold: int) -> void:
	gold_label.text = str(gold)


## Extra difficulty from cauldrons, as a fraction; hidden while it is 0.
func set_difficulty(bonus: float) -> void:
	if _difficulty_label == null:
		var stats := gold_label.get_parent()
		var gap := Control.new()
		gap.custom_minimum_size = Vector2(8, 0)
		gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stats.add_child(gap)
		stats.add_child(_icon(CAULDRON_ICON, 24.0))
		_difficulty_label = Label.new()
		_difficulty_label.add_theme_font_size_override("font_size", 22)
		_difficulty_label.add_theme_color_override("font_color", Palette.GREEN)
		stats.add_child(_difficulty_label)
	_difficulty_label.text = "+%d %%" % roundi(bonus * 100.0)
	for node in _difficulty_label.get_parent().get_children().slice(-3):
		node.visible = bonus > 0.0


func show_cauldron(difficulty_step: float, reward_step: float) -> void:
	_show_banner("¡Caldero maldito!\nDificultad +%d %%  ·  Experiencia y oro +%d %%" % [
		roundi(difficulty_step * 100.0), roundi(reward_step * 100.0)], Palette.GREEN, 2.4)


func show_chaos(text: String) -> void:
	_show_banner("¡Caos!\n%s" % text, Palette.PURPLE_LIGHT, 1.8)


func set_items(stacks: Dictionary) -> void:
	for child in item_icons.get_children():
		child.queue_free()
	for item: ItemData in stacks:
		var slot := PanelContainer.new()
		slot.add_theme_stylebox_override("panel", Palette.box(Color(Palette.NIGHT, 0.85), Rarity.color(item.rarity), 2, 0, 2.0, false))
		var holder := Control.new()
		holder.custom_minimum_size = Vector2(28, 28)
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(holder)
		var icon := TextureRect.new()
		icon.texture = item.icon
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		holder.add_child(icon)
		var count := Label.new()
		count.text = str(stacks[item])
		count.add_theme_font_size_override("font_size", 13)
		count.add_theme_constant_override("outline_size", 5)
		count.position = Vector2(19, 10)
		holder.add_child(count)
		item_icons.add_child(slot)


## Active power-ups with their countdown. `buffs` maps power-up name to seconds left.
func set_buffs(buffs: Dictionary) -> void:
	for kind: StringName in _shown_buffs.keys():
		if not buffs.has(kind):
			_shown_buffs[kind].queue_free()
			_shown_buffs.erase(kind)
	for kind: StringName in buffs:
		if not _shown_buffs.has(kind):
			var row := HBoxContainer.new()
			row.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var icon := TextureRect.new()
			icon.texture = PowerUps.icon(kind)
			icon.custom_minimum_size = Vector2(30, 30)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			row.add_child(icon)
			var label := Label.new()
			label.add_theme_font_size_override("font_size", 18)
			row.add_child(label)
			buff_icons.add_child(row)
			_shown_buffs[kind] = row
		(_shown_buffs[kind].get_child(1) as Label).text = str(ceili(buffs[kind]))


func show_message(text: String, color: Color, hold: float) -> void:
	_show_banner(text, color, hold)


func show_horde_started(title: String) -> void:
	_show_banner(title + "!", Palette.ORANGE, 1.4)


func set_passives(entries: Array[Dictionary]) -> void:
	for child in passive_icons.get_children():
		child.queue_free()
	for entry in entries:
		var holder := Control.new()
		holder.custom_minimum_size = Vector2(30, 30)
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var icon := TextureRect.new()
		icon.texture = entry.icon
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		holder.add_child(icon)
		var level := Label.new()
		level.text = str(entry.level)
		level.add_theme_font_size_override("font_size", 13)
		level.add_theme_constant_override("outline_size", 5)
		level.position = Vector2(21, 12)
		holder.add_child(level)
		passive_icons.add_child(holder)


func _show_banner(text: String, color: Color, hold: float) -> void:
	banner.text = text
	banner.add_theme_color_override("font_color", color)
	banner.visible = true
	banner.pivot_offset = banner.size / 2.0
	banner.scale = Vector2.ONE * 1.4
	banner.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(banner, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(banner, "modulate:a", 1.0, 0.2)
	tween.tween_property(banner, "modulate:a", 0.0, 0.4).set_delay(hold)
	tween.tween_callback(func() -> void: banner.visible = false)


func set_health(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	if _health_text != null:
		_health_text.text = "%d / %d" % [ceili(current), roundi(maximum)]


## Pixel-art fonts for the numbers that matter most.
func _decorate() -> void:
	time_label.add_theme_font_override("font", Palette.FONT_BOLD)
	level_label.add_theme_font_override("font", Palette.FONT_BOLD)
	(time_label.get_parent() as PanelContainer).add_theme_stylebox_override("panel",
		Palette.box(Color(Palette.NIGHT, 0.85), Palette.PURPLE_LIGHT, 3, 2, 6.0))


func _icon(texture: Texture2D, icon_size: float) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = texture
	icon.custom_minimum_size = Vector2(icon_size, icon_size)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return icon


func set_xp(current: int, needed: int, level: int) -> void:
	xp_bar.max_value = needed
	xp_bar.value = current
	level_label.text = "Nv %d" % level


func set_time(seconds: float) -> void:
	time_label.text = Settings.format_time(seconds)


func set_kills(kills: int) -> void:
	kills_label.text = str(kills)


func set_weapons(weapons: Array[Weapon]) -> void:
	for child in weapon_icons.get_children():
		child.queue_free()
	for weapon in weapons:
		var slot := PanelContainer.new()
		slot.add_theme_stylebox_override("panel", Palette.box(Color(Palette.NIGHT, 0.85), Palette.PURPLE_LIGHT, 2, 0, 4.0, false))
		var holder := Control.new()
		holder.custom_minimum_size = Vector2(40, 40)
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(holder)
		var icon := TextureRect.new()
		icon.texture = weapon.data.icon
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.offset_right = -6
		icon.offset_bottom = -6
		holder.add_child(icon)
		var level := Label.new()
		level.text = str(weapon.level)
		level.add_theme_font_size_override("font_size", 15)
		level.add_theme_color_override("font_color", Palette.GOLD)
		level.add_theme_constant_override("outline_size", 5)
		level.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
		level.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		level.grow_vertical = Control.GROW_DIRECTION_BEGIN
		level.offset_bottom = 6
		level.offset_right = 2
		holder.add_child(level)
		weapon_icons.add_child(slot)


func pause_button_rect() -> Rect2:
	return pause_button.get_global_rect() if pause_button.visible else Rect2()


func _on_input_mode_changed(touch: bool) -> void:
	pause_button.visible = touch


## Keeps the HUD clear of notches and rounded corners on phones.
func _apply_safe_area() -> void:
	var left := EDGE_MARGIN
	var top := EDGE_MARGIN
	var right := EDGE_MARGIN
	var bottom := EDGE_MARGIN
	if OS.has_feature("mobile"):
		var window := Vector2(DisplayServer.window_get_size())
		var safe := DisplayServer.get_display_safe_area()
		var to_viewport := get_viewport_rect().size / window
		left += int(safe.position.x * to_viewport.x)
		top += int(safe.position.y * to_viewport.y)
		right += int((window.x - safe.end.x) * to_viewport.x)
		bottom += int((window.y - safe.end.y) * to_viewport.y)
	margin.add_theme_constant_override("margin_left", left)
	margin.add_theme_constant_override("margin_top", top)
	margin.add_theme_constant_override("margin_right", right)
	margin.add_theme_constant_override("margin_bottom", bottom)
