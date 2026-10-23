class_name WaveTable
extends Resource
## Ordered list of wave entries describing a whole run.

@export var entries: Array[WaveEntry] = []


func entry_at(time: float) -> WaveEntry:
	var current := entries[0]
	for entry in entries:
		if time >= entry.start_time:
			current = entry
	return current


func index_at(time: float) -> int:
	return entries.find(entry_at(time))
