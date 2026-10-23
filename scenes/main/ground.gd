extends Sprite2D
## Endless ground: a repeated texture region that follows the camera in whole-tile steps,
## so the pattern stays fixed to the world.

## World area covered around the camera. Must exceed the largest visible area.
@export var cover := Vector2(4096, 4096)


func _ready() -> void:
	centered = true
	region_enabled = true
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	region_rect = Rect2(Vector2.ZERO, cover)


func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	var tile := texture.get_size()
	global_position = (camera.get_screen_center_position() / tile).floor() * tile
