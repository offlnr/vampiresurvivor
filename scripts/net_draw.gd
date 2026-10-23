class_name NetDraw
## Simple drawing commands that can be sent over the network. Nodes with a custom `_draw()`
## describe it as a list of these from `draw_ops()` and paint it with `paint()`, so the online
## guest can draw exactly the same thing (health bars, ember trails, vortices, brewing rings).
##
## Each op is an Array: [CIRCLE, center, radius, color], [ARC, center, radius, from, to, points,
## color, width], [RECT, rect, color].

const CIRCLE := 0
const ARC := 1
const RECT := 2


static func paint(canvas: CanvasItem, ops: Array) -> void:
	for op: Array in ops:
		match op[0]:
			CIRCLE:
				canvas.draw_circle(op[1], op[2], op[3])
			ARC:
				canvas.draw_arc(op[1], op[2], op[3], op[4], op[5], op[6], op[7], true)
			RECT:
				canvas.draw_rect(op[1], op[2])
