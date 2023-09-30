extends Line2D

var point
var target

func _ready():
	target = get_parent()
	var trails = get_tree().get_first_node_in_group("trails")
	target.remove_child.call_deferred(self)
	trails.add_child.call_deferred(self)
	
func _physics_process(_delta):
	if target == null:
		return
	point = target.global_position
	add_point(point)
	if points.size() > 1000:
		remove_point(0)
