extends CanvasLayer
@onready var boxes_container = %Boxes
@onready var failure = %Failure

@export var arena_time_manager: Node
@onready var label = %TimerLabel
@export var box_scene: PackedScene

func _ready():
	# Set signals from arena time manager
	arena_time_manager.new_delivery.connect(next_delivery)
	arena_time_manager.delivery_failed.connect(delivery_failed)
	arena_time_manager.delivery_completed.connect(delivery_completed)

func _process(_delta):
	if arena_time_manager == null:
		return
	var time_elapsed = arena_time_manager.get_time_remaining()
	# Convert seconds to string as minutes:seconds
	label.text = format_seconds_to_string(time_elapsed)
	
func format_seconds_to_string(seconds: float):
	var minutes = floor(seconds / 60)
	var remaining_seconds = seconds - (minutes * 60)
	var seconds_string = str(int(remaining_seconds)).pad_zeros(2)
	return str(int(minutes)) + ":" + seconds_string

func next_delivery(boxes: Array):
	for box in boxes:
		var new_box = box_scene.instantiate()
		boxes_container.add_child(new_box)
		

func delivery_failed():
	failure.visible = true
	for box in boxes_container.get_children():
		box.fade_out()

	
func delivery_completed():
	failure.visible = false
	for box in boxes_container.get_children():
		box.fade_out()
