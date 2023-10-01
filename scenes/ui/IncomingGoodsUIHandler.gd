extends Node

@export var inbound_label: Label
@export var incoming_goods_manager: Node
@export var box_scene: PackedScene
@export var boxes_container: Node
@export var failure: Label


func _ready():
	# Set signals from incoming_goods_manager
	incoming_goods_manager.new_delivery.connect(next_delivery)
	incoming_goods_manager.delivery_failed.connect(delivery_failed)
	incoming_goods_manager.delivery_completed.connect(delivery_completed)

func _process(_delta):
	if incoming_goods_manager == null:
		return
	var time_elapsed = incoming_goods_manager.get_time_remaining()
	# Convert seconds to string as minutes:seconds
	inbound_label.text = "Inbound " + format_seconds_to_string(time_elapsed)
	
func format_seconds_to_string(seconds: float):
	var minutes = floor(seconds / 60)
	var remaining_seconds = seconds - (minutes * 60)
	var seconds_string = str(int(remaining_seconds)).pad_zeros(2)
	return str(int(minutes)) + ":" + seconds_string

func next_delivery(boxes: Array):
	print("New delivery")
	for box in boxes:
		var new_box = box_scene.instantiate()
		new_box.set_boxtype(box)
		boxes_container.add_child(new_box)
		

func delivery_failed():
	failure.visible = true
	for box in boxes_container.get_children():
		box.fade_out()

	
func delivery_completed():
	failure.visible = false
	for box in boxes_container.get_children():
		box.fade_out()
