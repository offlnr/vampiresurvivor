extends Weapon
## A fog around the player that damages every enemy inside it each cooldown.

var _time := 0.0
var _pulse := 0.0

@onready var fog: Sprite2D = $Fog


func _on_level_changed() -> void:
	_apply_scale()


func _process(delta: float) -> void:
	_time += delta
	_pulse = maxf(_pulse - delta * 4.0, 0.0)
	fog.rotation += delta * 0.35
	fog.modulate.a = 0.8 + 0.12 * sin(_time * 2.0) + _pulse * 0.2
	_apply_scale()


func _attack() -> bool:
	var hit_damage := damage()
	var hit := enemies.in_radius(player.global_position, area())
	for enemy in hit:
		enemies.damage(enemy, hit_damage, enemy.position - player.global_position, 50.0)
	if not hit.is_empty():
		_pulse = 1.0
	return true


func _apply_scale() -> void:
	var diameter := area() * 2.0 * (1.0 + 0.04 * sin(_time * 1.7) + _pulse * 0.05)
	fog.scale = Vector2.ONE * (diameter / fog.texture.get_width())
