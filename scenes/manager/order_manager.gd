extends Node
class_name OrderManager
@export var order_ui: Node
@onready var timer: Timer = $Timer
@export var level: int = 1
var orders_table: WeightedTable = WeightedTable.new()
@export var level_1_orders: Array[OrderResource] = []

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
	if level == 1:
		for order in level_1_orders:
			orders_table.add_item(order, 10)

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
	var order_resource = orders_table.get_item()
	print("Next order is due in " + str(order_resource.time) + " seconds. It contains following boxes: "+ str(order_resource.boxes))
	var order = Order.new()
	order.time_left = order_resource.time
	order.order_resource = order_resource
	order.platform = free_platform
	# Add to current orders to platform
	current_orders[free_platform] = order

	# Add order to UI
	order_ui.add_order(order)

func check_order_completed(order):
	# Order is completed if corresponding platform area2d contains all boxes
	var platform = current_platforms[int(order.platform)]
	var boxes = platform.get_overlapping_bodies()
	var order_boxes = order.order_resource.boxes
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
