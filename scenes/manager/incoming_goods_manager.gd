extends Node
@onready var timer = $Timer
@export var box_scene: PackedScene
@export var game_manager: Node
var incoming_table: WeightedTable = WeightedTable.new()

signal new_delivery(boxes: Array)
signal delivery_failed
signal delivery_completed

var next_delivery = null

func get_time_elapsed():
	return timer.wait_time - timer.time_left


func get_time_remaining():
	return timer.time_left


func _ready():
	timer.timeout.connect(on_timer_timeout)
	timer.start()
	create_new_delivery()
	on_timer_timeout.call_deferred()


func create_new_delivery():
	# Get random item from table
	next_delivery = game_manager.get_random_boxes(game_manager.get_random_boxcount(true))
	emit_signal("new_delivery", next_delivery)


func on_timer_timeout():
	# Start next timer
	timer.start()

	# Check if incoming slot is empty
	var input_area = get_tree().get_first_node_in_group("input_area")
	var boxes = input_area.get_overlapping_bodies()
	if boxes.size() > 0:
		print("Incoming slot is full")
		emit_signal("delivery_failed")
		create_new_delivery()
		return
	emit_signal("delivery_completed")
	# Calculate spawn points using input area shape divided into equal parts
	var pos_x = input_area.global_position.x - 70
	var pos_y = input_area.global_position.y - 40
	var pos_index = 0
	for i in range(next_delivery.size()):
		var box = box_scene.instantiate() as Node2D
		box.box_type = next_delivery[i]
		var entities_layer = get_tree().get_first_node_in_group("entities_layer")
		entities_layer.add_child(box)
		if i > 0 and i % 4 == 0 :
			print("New row")
			pos_y += 60
			pos_x = input_area.global_position.x - 70
			pos_index = 0
		box.global_position = Vector2(pos_x + 60 * pos_index, pos_y)
		pos_index += 1
	create_new_delivery()

