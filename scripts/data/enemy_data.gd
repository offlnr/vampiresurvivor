class_name EnemyData
extends Resource
## Stats and look of one enemy type.

enum SpawnStyle { RISE, FADE, DROP }
## CHASE walks into the player; EXPLODER blows up next to them; RANGED keeps its distance and throws potions.
enum Behavior { CHASE, EXPLODER, RANGED }
## Boss attacks (see EnemyManager): a ring of potions, a ground slam with a warning circle, and
## calling minions.
enum BossAttack { RING, SLAM, SUMMON }

@export var id: StringName
@export var display_name := ""
## Animation frames; the "move" animation plays while the enemy is alive.
@export var frames: SpriteFrames
## Height in world units the sprite is scaled to, whatever the texture size.
@export var visual_height := 56.0
## Collision radius in world units. Independent of the sprite.
@export var radius := 16.0
@export var speed := 80.0
@export var max_health := 10.0
@export var contact_damage := 5.0
@export var xp_value := 1
## Chance of dropping a gold coin on death.
@export var gold_chance := 0.1
@export var tint := Color.WHITE
## How the enemy enters the world: rising from the ground, fading in or dropping from above.
@export var spawn_style := SpawnStyle.RISE
## Floating enemies hover and fade instead of walking.
@export var floaty := false
## Flies over crypts, trees and other solid props instead of walking around them.
@export var flying := false
@export var behavior := Behavior.CHASE
@export var knockback_immune := false

@export_group("Attack")
## Explosion or potion damage.
@export var attack_damage := 0.0
## Explodes or starts throwing within this distance of the player.
@export var attack_range := 0.0
@export var attack_cooldown := 2.5
@export var projectile_speed := 220.0

@export_group("Boss")
## Attacks a boss uses in turn, one every `attack_cooldown` seconds (BossAttack values).
@export var boss_attacks: Array[int] = []


func frame_texture() -> Texture2D:
	return frames.get_frame_texture(&"move", 0)
