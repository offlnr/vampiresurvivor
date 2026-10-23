class_name SpatialGrid
extends RefCounted
## Uniform grid used to find nearby items without physics queries.

var cell_size: float
var _cells := {}


func _init(size := 64.0) -> void:
	cell_size = size


func clear() -> void:
	_cells.clear()


func insert(item: Object, pos: Vector2) -> void:
	var key := _cell(pos)
	var bucket: Array = _cells.get(key, [])
	if bucket.is_empty():
		_cells[key] = bucket
	bucket.append(item)


## Returns candidates in the cells overlapping the circle; callers filter by distance.
func query(pos: Vector2, radius: float) -> Array:
	var result := []
	var from := _cell(pos - Vector2(radius, radius))
	var to := _cell(pos + Vector2(radius, radius))
	for x in range(from.x, to.x + 1):
		for y in range(from.y, to.y + 1):
			var bucket: Array = _cells.get(Vector2i(x, y), [])
			if not bucket.is_empty():
				result.append_array(bucket)
	return result


func _cell(pos: Vector2) -> Vector2i:
	return Vector2i(floori(pos.x / cell_size), floori(pos.y / cell_size))
