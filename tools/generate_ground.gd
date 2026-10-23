extends SceneTree
## Generates art/placeholder/ground.svg: a seamless 1024 px night-soil tile with only
## soft patches, grass and pebbles. Graves, trees and other props are placed by
## scenes/main/decorations.gd instead, so they don't repeat in a grid.
##
## Run from the project folder:
##   godot --headless --path . --script tools/generate_ground.gd

const SIZE := 1024
const SEED := 1031
const OUT := "res://art/placeholder/ground.svg"

var _rng := RandomNumberGenerator.new()
var _parts: PackedStringArray = []


func _initialize() -> void:
	_rng.seed = SEED
	_parts.append('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">' % [SIZE, SIZE, SIZE, SIZE])
	_parts.append('<rect width="%d" height="%d" fill="#1B1626"/>' % [SIZE, SIZE])
	# Large soft patches of lighter and darker soil.
	for i in 26:
		_wrapped_ellipse(_rng.randf_range(90, 200), _rng.randf_range(60, 130), "#211A2E", 0.85)
	for i in 22:
		_wrapped_ellipse(_rng.randf_range(60, 150), _rng.randf_range(40, 100), "#171220", 0.9)
	for i in 14:
		_wrapped_ellipse(_rng.randf_range(50, 110), _rng.randf_range(30, 70), "#1D2124", 0.55)
	# Grass tufts.
	for i in 220:
		var x := _rng.randf() * SIZE
		var y := _rng.randf() * SIZE
		var color: String = ["#2B3326", "#303A2B", "#26302A"][_rng.randi() % 3]
		var h := _rng.randf_range(5, 10)
		_wrapped('<path d="M%.1f %.1f L%.1f %.1f L%.1f %.1f L%.1f %.1f L%.1f %.1f L%.1f %.1f L%.1f %.1f Z" fill="%s"/>',
			[x, y, x + 2, y - h, x + 5, y, x + 7, y - h - 2, x + 9, y, x + 11, y - h + 2, x + 12, y], [color], x, y, 16)
	# Pebbles.
	for i in 90:
		var x := _rng.randf() * SIZE
		var y := _rng.randf() * SIZE
		var r := _rng.randf_range(1.5, 3.5)
		_wrapped('<ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" fill="%s"/>', [x, y], [r * 1.4, r, "#2A2238"], x, y, 8)
	_parts.append("</svg>")
	var file := FileAccess.open(OUT, FileAccess.WRITE)
	file.store_string("\n".join(_parts) + "\n")
	file.close()
	print("wrote ", OUT, " (", _parts.size(), " elements)")
	quit()


func _wrapped_ellipse(rx: float, ry: float, color: String, opacity: float) -> void:
	var x := _rng.randf() * SIZE
	var y := _rng.randf() * SIZE
	var shape := '<ellipse cx="%.1f" cy="%.1f" rx="%.1f" ry="%.1f" fill="%s" fill-opacity="%.2f"/>'
	for offset in _copies(x, y, maxf(rx, ry)):
		_parts.append(shape % [x + offset.x, y + offset.y, rx, ry, color, opacity])


## Adds a shape, plus copies shifted by the tile size when it crosses an edge, so the tile is seamless.
## `coords` are x, y pairs that get shifted; `extras` (sizes, colour) are appended unchanged.
func _wrapped(shape: String, coords: Array, extras: Array, x: float, y: float, reach: float) -> void:
	for offset in _copies(x, y, reach):
		var args := []
		for i in coords.size():
			args.append(coords[i] + (offset.x if i % 2 == 0 else offset.y))
		args.append_array(extras)
		_parts.append(shape % args)


func _copies(x: float, y: float, reach: float) -> Array[Vector2]:
	var result: Array[Vector2] = []
	for dx in [-SIZE, 0, SIZE]:
		for dy in [-SIZE, 0, SIZE]:
			if x + dx + reach >= 0 and x + dx - reach <= SIZE and y + dy + reach >= 0 and y + dy - reach <= SIZE:
				result.append(Vector2(dx, dy))
	return result
