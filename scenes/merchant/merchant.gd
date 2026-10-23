class_name Merchant
extends Node2D
## The shady merchant: hat colour shows the rarity of the three items he sells.

const BODY_HEIGHT := 84.0

var rarity := Rarity.Tier.COMMON
var offers: Array[ItemData] = []
var life_left := 60.0
var _time := 0.0

@onready var body: Sprite2D = $Body
@onready var hat: Sprite2D = $Body/Hat
@onready var glow: Sprite2D = $Glow
@onready var label: Label = $Label


func setup(merchant_rarity: int, items: Array[ItemData], lifetime: float) -> void:
	rarity = merchant_rarity
	offers = items
	life_left = lifetime
	hat.modulate = Rarity.color(rarity)
	glow.modulate = Color(Rarity.color(rarity), 0.45)
	label.text = Rarity.name_of(rarity)
	label.add_theme_color_override("font_color", Rarity.color(rarity))
	scale = Vector2.ZERO
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	_time += delta
	body.position.y = -BODY_HEIGHT * 0.5 + sin(_time * 2.0) * 4.0
	glow.scale = Vector2.ONE * (2.2 + 0.2 * sin(_time * 3.0))
	# Fades during his last seconds, to show he is about to leave.
	modulate.a = 1.0 if life_left > 5.0 else 0.4 + 0.6 * absf(sin(_time * 6.0))
