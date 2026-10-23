class_name UiCards
extends RefCounted
## Compact pixel-art card rows used by level-ups, the merchant and chests:
## [ icon | rarity · tag / name / description / footer ] [reroll] [banish]

const CARD_SIZE := Vector2(560, 104)
const HEADER_SIZE := 16
const TITLE_SIZE := 24
const BODY_SIZE := 18
## Rough width of one character of the pixel font, as a share of its size (to size cards to their text).
const CHAR_WIDTH := 0.4
const ICON_SIZE := 56.0
const REROLL_ICON := preload("res://art/placeholder/ui/reroll.svg")
const BANISH_ICON := preload("res://art/placeholder/ui/banish.svg")


## Builds a full row. `footer` (optional) is shown under the description, e.g. a price.
static func make_row(icon: Texture2D, rarity: int, tag: String, title: String, description: String,
		on_pick: Callable, can_reroll: bool, can_banish: bool, on_reroll: Callable, on_banish: Callable,
		footer: Control = null, enabled := true) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	var card := _card(icon, rarity, tag, title, description, footer, enabled)
	card.pressed.connect(on_pick)
	row.add_child(card)
	var actions := VBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_child(_action(REROLL_ICON, "Volver a tirar", can_reroll, on_reroll))
	actions.add_child(_action(BANISH_ICON, "Desterrar", can_banish, on_banish))
	row.add_child(actions)
	return row


## Uses left of each card action; skips are left out where they don't apply (shops).
static func counter_text(rerolls: int, banishes: int, skips := -1) -> String:
	var text := "Tiradas %d   ·   Destierros %d" % [rerolls, banishes]
	return text if skips < 0 else text + "   ·   Saltos %d" % skips


static func _card(icon: Texture2D, rarity: int, tag: String, title: String, description: String,
		footer: Control, enabled: bool) -> Button:
	var color := Rarity.color(rarity)
	var button := Button.new()
	button.custom_minimum_size = CARD_SIZE
	button.disabled = not enabled
	button.add_theme_stylebox_override("normal", _card_box(Palette.NIGHT.lerp(color, 0.10), color, rarity))
	button.add_theme_stylebox_override("hover", _card_box(Palette.NIGHT.lerp(color, 0.25), color.lightened(0.35), rarity))
	button.add_theme_stylebox_override("pressed", _card_box(Palette.NIGHT.lerp(color, 0.30), color.lightened(0.35), rarity))
	button.add_theme_stylebox_override("disabled", _card_box(Palette.NIGHT, Color(color, 0.35), 0))

	var content := HBoxContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 10)
	content.add_theme_constant_override("separation", 12)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.modulate.a = 1.0 if enabled else 0.5
	button.add_child(content)

	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE) + Vector2(12, 12)
	frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", Palette.box(Color(Palette.INK, 0.6), color, 2, 0, 4.0, false))
	var icon_rect := TextureRect.new()
	icon_rect.texture = icon
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(icon_rect)
	content.add_child(frame)

	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.alignment = BoxContainer.ALIGNMENT_CENTER
	text.add_theme_constant_override("separation", 0)
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(text)
	var header := _label("%s  ·  %s" % [Rarity.name_of(rarity).to_upper(), tag] if tag != "" else Rarity.name_of(rarity).to_upper(), HEADER_SIZE, color)
	text.add_child(header)
	var name_label := _label(title, TITLE_SIZE, Palette.ORANGE)
	name_label.add_theme_font_override("font", Palette.FONT_BOLD)
	text.add_child(name_label)
	var body := _label(description, BODY_SIZE, Palette.BONE)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var text_width := CARD_SIZE.x - ICON_SIZE - 70
	body.custom_minimum_size.x = text_width
	text.add_child(body)
	if footer != null:
		footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		text.add_child(footer)
	# The card grows with its text: header + title + wrapped description + optional footer.
	var lines := ceili(description.length() * BODY_SIZE * CHAR_WIDTH / text_width)
	var height := 24.0 + HEADER_SIZE + TITLE_SIZE + 6 + lines * (BODY_SIZE + 4) + (24.0 if footer != null else 0.0)
	button.custom_minimum_size.y = maxf(CARD_SIZE.y, height)
	return button


static func _card_box(bg: Color, border: Color, rarity: int) -> StyleBoxFlat:
	var style := Palette.box(bg, border, 3, 2, 8.0)
	# Epic and legendary cards glow in their rarity colour.
	if rarity >= Rarity.Tier.EPIC:
		style.shadow_color = Color(border, 0.5)
		style.shadow_size = 6 + 4 * (rarity - Rarity.Tier.EPIC)
		style.shadow_offset = Vector2.ZERO
	return style


static func _action(icon: Texture2D, tooltip: String, enabled: bool, action: Callable) -> Button:
	var button := Button.new()
	button.icon = icon
	button.expand_icon = true
	button.tooltip_text = tooltip
	button.custom_minimum_size = Vector2(46, 46)
	button.add_theme_constant_override("icon_max_width", 26)
	button.disabled = not enabled
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(func() -> void:
		Audio.play(&"click", 0.0)
		action.call())
	return button


static func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", 5)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label
