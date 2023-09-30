extends Node
@onready var timer = $Timer
@export var box_scene: PackedScene

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
	incoming_table.add_item([0, 0, 0], 10)
	incoming_table.add_item([0], 10)
	incoming_table.add_item([0, 0, 0, 0], 10)
	timer.start()
	create_new_delivery()


func create_new_delivery():



	# Get random item from table
	var item = incoming_table.get_item()
	next_delivery = item
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
	var pos_y = input_area.global_position.y - 60

	for i in range(next_delivery.size()):
		var box = box_scene.instantiate() as Node2D
		var entities_layer = get_tree().get_first_node_in_group("entities_layer")
		entities_layer.add_child(box)
		if i % 4 == 0:
			pos_y += 30
			pos_x = input_area.global_position.x - 70
		box.global_position = Vector2(pos_x + 60 * i, pos_y)
	create_new_delivery()

