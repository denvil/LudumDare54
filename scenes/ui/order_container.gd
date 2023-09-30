extends PanelContainer
@onready var boxes = %Boxes
@onready var reward_label = %RewardLabel
@onready var penalty_label = %PenaltyLabel
@onready var time_left = %TimeLeft
@onready var platform = %PlatformLabel

@export var boxes_scene: PackedScene

var current_order: Order = null

func _ready():
	pass

func update_time():
	time_left.value = 1 - (current_order.time_left / current_order.order_resource.time)
	if time_left.value > 0.7:
		time_left.modulate = Color.ORANGE_RED

func setup(order: Order):
	reward_label.text = str(order.order_resource.reward)
	penalty_label.text = str(order.order_resource.penalty)
	current_order = order
	update_time()
	platform.text = "Platform "+str(int(order.platform)+1)
	
	# Map signals
	current_order.update_order.connect(on_update_order)
	current_order.fail_order.connect(on_fail_order)
	current_order.complete_order.connect(on_complete_order)
	
	# Map order boxes
	for box in current_order.order_resource.boxes:
		var box_instance = boxes_scene.instantiate()
		boxes.add_child(box_instance)
			


func on_update_order(_order: Order):
	update_time()
	
func on_fail_order(_order: Order):
	queue_free()

func on_complete_order(_order: Order):
	queue_free()

