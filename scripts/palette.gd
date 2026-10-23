class_name Palette
extends RefCounted
## Halloween colour palette and the UI theme built from it.

const NIGHT := Color("14101e")
const NIGHT_LIGHT := Color("231b33")
const PURPLE := Color("6b2fa8")
const PURPLE_LIGHT := Color("a66be0")
const PURPLE_DARK := Color("2a1a40")
const ORANGE := Color("ff7a1a")
const ORANGE_DARK := Color("c44a00")
const GREEN := Color("8be04e")
const BONE := Color("f2e8d5")
const RED := Color("e0344a")
const GOLD := Color("ffd25a")
const INK := Color("0b0812")


const FONT := preload("res://art/fonts/ui_font.tres")
const FONT_BOLD := preload("res://art/fonts/ui_font_bold.tres")
## Offset of the hard "pixel" drop shadow under panels and buttons.
const SHADOW_OFFSET := Vector2(4, 4)


## Square pixel-art box: flat colour, hard border and an optional block shadow.
static func box(bg: Color, border: Color, border_width := 3, radius := 2, padding := 14.0, shadow := true) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(padding)
	style.anti_aliasing = false
	if shadow:
		style.shadow_color = Color(INK, 0.85)
		style.shadow_size = 1
		style.shadow_offset = SHADOW_OFFSET
	return style


## Raised pixel button: thicker bottom edge that shrinks when pressed.
static func button_box(bg: Color, border: Color, pressed := false) -> StyleBoxFlat:
	var style := box(bg, border, 3, 2, 12.0, not pressed)
	style.border_width_bottom = 3 if pressed else 7
	style.content_margin_top = 14 if pressed else 10
	return style


static func bar(fill: Color) -> Array[StyleBoxFlat]:
	var background := box(Color(INK, 0.85), INK, 3, 0, 0.0, false)
	var foreground := box(fill, Color(0, 0, 0, 0), 0, 0, 0.0, false)
	foreground.expand_margin_top = -3
	foreground.expand_margin_bottom = -3
	foreground.expand_margin_left = -3
	foreground.expand_margin_right = -3
	return [background, foreground]


static func build_theme() -> Theme:
	var theme := Theme.new()
	theme.default_font = FONT
	theme.default_font_size = 24

	theme.set_color("font_color", "Label", BONE)
	theme.set_color("font_outline_color", "Label", INK)
	theme.set_constant("outline_size", "Label", 8)

	theme.set_font("font", "Button", FONT_BOLD)
	theme.set_stylebox("normal", "Button", button_box(PURPLE_DARK, PURPLE_LIGHT))
	theme.set_stylebox("hover", "Button", button_box(PURPLE, ORANGE))
	theme.set_stylebox("pressed", "Button", button_box(ORANGE_DARK, ORANGE, true))
	theme.set_stylebox("hover_pressed", "Button", button_box(ORANGE_DARK, ORANGE, true))
	theme.set_stylebox("disabled", "Button", button_box(PURPLE_DARK.darkened(0.45), PURPLE_DARK))
	var focus := box(Color(0, 0, 0, 0), GOLD, 3, 2, 12.0, false)
	focus.draw_center = false
	focus.expand_margin_left = 4
	focus.expand_margin_right = 4
	focus.expand_margin_top = 4
	focus.expand_margin_bottom = 4
	theme.set_stylebox("focus", "Button", focus)
	theme.set_color("font_color", "Button", BONE)
	theme.set_color("font_hover_color", "Button", Color.WHITE)
	theme.set_color("font_pressed_color", "Button", Color.WHITE)
	theme.set_color("font_focus_color", "Button", Color.WHITE)
	theme.set_color("font_hover_pressed_color", "Button", Color.WHITE)
	theme.set_color("font_disabled_color", "Button", Color(BONE, 0.35))
	theme.set_color("font_outline_color", "Button", INK)
	theme.set_constant("outline_size", "Button", 6)
	theme.set_constant("h_separation", "Button", 10)

	var panel := box(Color(NIGHT, 0.96), PURPLE_LIGHT, 4, 2, 26.0)
	panel.shadow_offset = Vector2(6, 6)
	theme.set_stylebox("panel", "PanelContainer", panel)

	var bars := bar(GREEN)
	theme.set_stylebox("background", "ProgressBar", bars[0])
	theme.set_stylebox("fill", "ProgressBar", bars[1])
	theme.set_color("font_color", "ProgressBar", BONE)

	var slider := box(INK, PURPLE_LIGHT, 3, 0, 0.0, false)
	slider.content_margin_top = 7
	slider.content_margin_bottom = 7
	theme.set_stylebox("slider", "HSlider", slider)
	var grabber_area := box(ORANGE, Color(0, 0, 0, 0), 0, 0, 0.0, false)
	grabber_area.content_margin_top = 7
	grabber_area.content_margin_bottom = 7
	theme.set_stylebox("grabber_area", "HSlider", grabber_area)
	theme.set_stylebox("grabber_area_highlight", "HSlider", grabber_area)
	theme.set_icon("grabber", "HSlider", preload("res://art/placeholder/ui/knob.svg"))
	theme.set_icon("grabber_highlight", "HSlider", preload("res://art/placeholder/ui/knob_hover.svg"))
	return theme
