extends Node2D
## A thrown projectile (pumpkin, magic orb). Damages the enemies it touches until it runs out of pierce or time.

## Radians per second the sprite turns while flying.
@export var spin_speed := 9.0

var weapon: Weapon
var velocity := Vector2.ZERO
var damage := 0.0
var pierce_left := 0
var radius := 16.0
var life := 0.0

var _hit := {}

@onready var sprite: Sprite2D = $Sprite


func launch(owner_weapon: Weapon, pos: Vector2, direction: Vector2) -> void:
	weapon = owner_weapon
	position = pos
	velocity = direction * weapon.stat(&"speed")
	damage = weapon.damage()
	pierce_left = int(weapon.stat(&"pierce"))
	# Disappears once it has travelled the weapon's range.
	life = weapon.data.attack_range / weapon.stat(&"speed")
	var size := weapon.area()
	radius = size * 0.5
	sprite.scale = Vector2.ONE * (size / sprite.texture.get_width())
	_hit.clear()


func _physics_process(delta: float) -> void:
	position += velocity * delta
	sprite.rotation += delta * spin_speed * signf(velocity.x if velocity.x != 0.0 else 1.0)
	life -= delta
	if life <= 0.0:
		weapon.release_projectile(self)
		return
	for enemy in weapon.enemies.in_radius(position, radius):
		if _hit.has(enemy):
			continue
		_hit[enemy] = true
		weapon.enemies.damage(enemy, damage, velocity, 140.0, EnemyManager.SOURCE_WEAPON, weapon.player)
		pierce_left -= 1
		if pierce_left < 0:
			weapon.release_projectile(self)
			return
