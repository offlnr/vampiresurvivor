class_name WaveEntry
extends Resource
## Spawn rules from start_time until the next entry of the table begins.

@export var start_time := 0.0
@export var enemies: Array[EnemyData] = []
## Relative spawn weight for each enemy, same order as `enemies`.
@export var weights: PackedFloat32Array
@export var spawn_interval := 1.0
@export var spawn_batch := 2
@export var max_alive := 40
## Multiplies enemy health in this part of the run (enemies get stronger with time, as in Megabonk).
@export var health_multiplier := 1.0
## Multiplies every enemy's speed, so enemies start slow and speed up during the run.
@export var speed_multiplier := 1.0


func pick_enemy() -> EnemyData:
	var total := 0.0
	for i in enemies.size():
		total += _weight(i)
	var roll := randf() * total
	for i in enemies.size():
		roll -= _weight(i)
		if roll <= 0.0:
			return enemies[i]
	return enemies.back()


func _weight(index: int) -> float:
	return weights[index] if index < weights.size() else 1.0
