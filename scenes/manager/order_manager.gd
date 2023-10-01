extends Node
class_name OrderManager
@export var order_ui: Node

@onready var difficulty_timer = $DifficultyTimer
@onready var timer: Timer = $Timer
@export var level: int = 0

@export var box_selection_curve: Curve
@export var box_count_curve: Curve
@export var time_curve: Curve


var current_orders: Dictionary = {
	"0": null,
	"1": null,
	"2": null,
}

@export var current_platforms:Array[Area2D]=[]

signal order_completed(order: Order)
signal order_failed(order: Order)

func _ready():
	timer.timeout.connect(on_timer_timeout)
	difficulty_timer.timeout.connect(on_difficulty_timer_timeout)


func on_difficulty_timer_timeout():
	level += 1
	print("Difficulty updated to "+str(level))
	if level > 10:
		level = 10


func get_random_boxcount():
	return randi_range(1, ceil(box_count_curve.sample(level/10.0)))

func get_random_boxes(count):
	var boxes = []
	for i in range(count):
		var box_type = randi_range(0, floor(box_selection_curve.sample(level/10.0)))
		if box_type > 2:
			box_type = 2
		boxes.append(box_type)
	return boxes

func new_order():
	var order = Order.new()
	# Generate boxes where curve is max count using random
	var box_count = get_random_boxcount()
	order.boxes.append_array(get_random_boxes(box_count))
	order.time = box_count * randi_range(20, ceil(time_curve.sample(level/10.0)))
	order.time_left = order.time
	order.reward = box_count * 100
	order.penalty = box_count * 50
	return order

func on_timer_timeout():
	# Start next timer
	timer.start()

	# Get free platform
	var free_platform = null
	for platform in current_orders:
		if current_orders[platform] == null:
			free_platform = platform
			break
	if free_platform == null:
		print("No free platforms")
		return

	# Generate new order
	
	var order = new_order()
	order.platform = free_platform
	print("Next order is due in " + str(order.time) + " seconds. It contains following boxes: "+ str(order.boxes))
	# Add to current orders to platform
	current_orders[free_platform] = order

	# Add order to UI
	order_ui.add_order(order)

func check_order_completed(order):
	# Order is completed if corresponding platform area2d contains all boxes
	var platform = current_platforms[int(order.platform)]
	var boxes = platform.get_overlapping_bodies()
	var order_boxes = order.boxes
	# Check that there is enough boxes in the platform
	if boxes.size() < order_boxes.size():
		return
	var boxes_to_be_found = order_boxes.duplicate()
	var found_boxes = []
	for box in boxes:
			if box.on_ground == false:
				continue
			var box_index = boxes_to_be_found.find(box.box_type)
			if box_index != -1:
				boxes_to_be_found.remove_at(box_index)
				found_boxes.append(box)
	if boxes_to_be_found.size() == 0:
		print("Order completed")
		order.complete()
		emit_signal("order_completed", order)
		order.queue_free()
		current_orders[order.platform] = null
		# Remove boxes remove function
		for box in found_boxes:
			box.remove()

func _process(delta):
	# Update orders
	for platform in current_orders:
		var order = current_orders[platform]
		if order == null:
			continue
		order.time_left -= delta
		order.update()
		if order.time_left <= 0:
			print("Order failed")
			current_orders[order.platform] = null
			order.fail()
			emit_signal("order_failed", order)
			order.queue_free()
		else: 
			# Check if order is complete
			check_order_completed(order)
