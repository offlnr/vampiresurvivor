class_name ObjectPool
extends RefCounted
## Reuses nodes instead of instantiating and freeing them during play.
## Released nodes stay in the tree, hidden and with processing disabled.

var active: Array = []

var _factory: Callable
var _parent: Node
var _free: Array = []


func _init(factory: Callable, parent: Node) -> void:
	_factory = factory
	_parent = parent


func acquire() -> Node:
	var node: Node
	if _free.is_empty():
		node = _factory.call()
		_parent.add_child(node)
	else:
		node = _free.pop_back()
	node.visible = true
	node.process_mode = Node.PROCESS_MODE_INHERIT
	active.append(node)
	return node


func release(node: Node) -> void:
	var index := active.find(node)
	if index == -1:
		return
	active[index] = active.back()
	active.pop_back()
	node.visible = false
	node.process_mode = Node.PROCESS_MODE_DISABLED
	_free.append(node)


## Total nodes created by this pool, in use or not.
func size() -> int:
	return active.size() + _free.size()
