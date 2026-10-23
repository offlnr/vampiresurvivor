extends Node
## Global signal bus for game events that several systems react to.

signal enemy_killed(enemy_data: EnemyData, position: Vector2)
signal xp_collected(amount: int)
signal player_damaged(current: float, maximum: float)
signal player_died
signal level_up(new_level: int)
signal run_ended(victory: bool)
