extends Camera2D

var target_position = Vector2.ZERO
var target_node = null
func _ready():
	make_current()

func _process(delta):
	if target_node == null:
		target_node = get_tree().get_first_node_in_group("player")

	target_position = target_node.position
	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * 20))
