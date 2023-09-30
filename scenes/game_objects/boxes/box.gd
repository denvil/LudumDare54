extends RigidBody2D
class_name Box
@onready var visuals = $Visuals

signal picked_up
signal dropped(box)

@export var on_ground: bool =  true

@export var box_type: int = 0

func _ready():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Visuals, "scale", Vector2(1.5,1.5), 0.3)

func picked_up_finished():
	emit_signal("picked_up")

func dropped_finished():
	emit_signal("dropped", self)
	on_ground = true

func remove():
	set_collision_layer_value(3, false)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.0,0.0), 0.3)
	tween.tween_callback(queue_free)

func pickup():
	# Pick up the object.
	# Disable collisions with the player.
	set_collision_layer_value(3, false)
	print("Picked up the box.")
	freeze = true
	on_ground = false


	# Find player node using groups and reparent to it.
	var player = get_tree().get_first_node_in_group("player")
	# Save current global_position
	var location = global_position
	# Save current orientation
	var orientation = global_rotation
	# Reparent to player
	get_parent().remove_child(self)
	player.add_child(self)
	# Set global_position to saved location
	global_position = location
	# Set global_rotation to saved orientation
	global_rotation = orientation

	# Tween to move box to player
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel(true)
	tween.tween_property(self, "position", Vector2(26.5,0), 0.3)
	tween.tween_property(self, "rotation", 0, 0.3)
	tween.set_parallel(false)
	tween.tween_property(self, "scale", Vector2(1.2,1.2), 0.3)
	tween.tween_callback(picked_up_finished)


func drop():
	# Drop the object.
	# Enable collisions with the player.
	set_collision_layer_value(3, true)
	print("Dropped the box.")
	freeze = false
	# Remove from player and reparent to world.
	# Get entities group to reparent
	var entities = get_tree().get_first_node_in_group("entities_layer")
	# Save current global_position
	var location = global_position
	# Save current orientation
	var orientation = global_rotation
	# Reparent to entities
	get_parent().remove_child(self)
	entities.add_child(self)
	# Set global_position to saved location
	global_position = location
	global_rotation = orientation

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.3)
	tween.tween_callback(dropped_finished)

