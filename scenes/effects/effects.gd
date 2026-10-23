class_name Effects
extends Node2D
## Short-lived visual feedback: damage numbers, death puffs and level-up rings. All pooled.

const PUFF_TEXTURE := preload("res://art/placeholder/puff.svg")
const RING_TEXTURE := preload("res://art/placeholder/ring.svg")
const MAX_DAMAGE_NUMBERS := 80

var _numbers: ObjectPool
var _puffs: ObjectPool
var _font_settings := LabelSettings.new()


func _ready() -> void:
	_font_settings.font_size = 22
	_font_settings.font_color = Palette.BONE
	_font_settings.outline_size = 6
	_font_settings.outline_color = Palette.INK
	_numbers = ObjectPool.new(_new_number, self)
	_puffs = ObjectPool.new(_new_puff, self)


func damage_number(pos: Vector2, amount: float, color := Palette.BONE, big := false) -> void:
	if _numbers.active.size() >= MAX_DAMAGE_NUMBERS:
		return
	var label: Label = _numbers.acquire()
	label.text = str(roundi(amount)) + ("!" if big else "")
	label.position = pos + Vector2(randf_range(-10, 10), 0) - label.size / 2.0
	label.modulate = Color(color.r / Palette.BONE.r, color.g / Palette.BONE.g, color.b / Palette.BONE.b)
	label.scale = Vector2.ONE * (1.9 if big else 1.3)
	var tween := label.create_tween()
	tween.tween_property(label, "scale", Vector2.ONE, 0.12)
	tween.parallel().tween_property(label, "position:y", label.position.y - 34.0, 0.55).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.25).set_delay(0.3)
	tween.tween_callback(_numbers.release.bind(label))


func puff(pos: Vector2, tint: Color) -> void:
	_burst(pos, PUFF_TEXTURE, Color(tint.lerp(Palette.BONE, 0.5), 0.9), 0.5, 1.6, 0.35)


## Leaves the enemy's last frame behind, squashing and fading, plus a puff.
func death(enemy: Enemy) -> void:
	var sprite: Sprite2D = _puffs.acquire()
	sprite.texture = enemy.current_texture()
	sprite.position = enemy.position + enemy.sprite.position
	sprite.flip_h = enemy.sprite.flip_h
	sprite.modulate = Color(enemy.data.tint, enemy.data.tint.a)
	var base := enemy.visual_scale()
	sprite.scale = Vector2.ONE * base
	var tween := sprite.create_tween()
	tween.tween_property(sprite, "scale", Vector2(base * 1.35, base * 0.25), 0.22).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(sprite, "modulate", Color(Palette.BONE, 0.0), 0.22)
	tween.tween_callback(_puffs.release.bind(sprite))
	sprite.flip_h = enemy.sprite.flip_h
	puff(enemy.position, enemy.data.tint)


## Expanding ring used by items and power-ups. `size` 1 is about a level-up ring.
func shockwave(pos: Vector2, color: Color, size: float) -> void:
	_burst(pos, RING_TEXTURE, color, 0.2 * size, 2.0 * size, 0.4)


func level_ring(pos: Vector2) -> void:
	_burst(pos, RING_TEXTURE, Palette.GOLD, 0.3, 2.2, 0.5)


func _burst(pos: Vector2, texture: Texture2D, color: Color, from_scale: float, to_scale: float, time: float) -> void:
	var sprite: Sprite2D = _puffs.acquire()
	sprite.texture = texture
	sprite.flip_h = false
	sprite.position = pos
	sprite.modulate = color
	sprite.scale = Vector2.ONE * from_scale
	var tween := sprite.create_tween()
	tween.tween_property(sprite, "scale", Vector2.ONE * to_scale, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, time)
	tween.tween_callback(_puffs.release.bind(sprite))


func _new_number() -> Label:
	var label := Label.new()
	label.label_settings = _font_settings
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(60, 30)
	label.pivot_offset = label.size / 2.0
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 20
	return label


func _new_puff() -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.z_index = 10
	return sprite
