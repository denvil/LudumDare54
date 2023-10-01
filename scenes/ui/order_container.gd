extends PanelContainer
@onready var boxes = %Boxes
@onready var reward_label = %RewardLabel
@onready var penalty_label = %PenaltyLabel
@onready var time_left = %TimeLeft
@onready var platform = %PlatformLabel

@export var boxes_scene: PackedScene

var current_order: Order = null

func _ready():
	var tween = create_tween()
	pivot_offset = Vector2(0, size.y / 2)
	tween.tween_property(self, "scale", Vector2(0, 1), 0)
	tween.tween_property(self, "scale", Vector2.ONE, 0.4)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)

func update_time():
	time_left.value = 1 - (current_order.time_left / current_order.time)
	if time_left.value > 0.7:
		time_left.modulate = Color.ORANGE_RED

func setup(order: Order):
	reward_label.text = str(order.reward)
	penalty_label.text = str(order.penalty)
	current_order = order
	update_time()
	platform.text = "Platform "+str(int(order.platform)+1)
	
	# Map signals
	current_order.update_order.connect(on_update_order)
	current_order.fail_order.connect(on_fail_order)
	current_order.complete_order.connect(on_complete_order)
	
	# Map order boxes
	for box in current_order.boxes:
		var box_instance = boxes_scene.instantiate()
		box_instance.set_boxtype(box)
		boxes.add_child(box_instance)
			


func on_update_order(_order: Order):
	update_time()
	
func on_fail_order(_order: Order):
	var tween = create_tween()
	pivot_offset = Vector2(0, size.y / 2)
	tween.tween_property(self, "modulate", Color.ORANGE_RED, 0.4)
	tween.tween_property(self, "scale",  Vector2(0, 1), 0.4)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(queue_free)

func on_complete_order(_order: Order):
	var tween = create_tween()
	pivot_offset = Vector2(0, size.y / 2)
	tween.tween_property(self, "modulate", Color.GREEN, 0.4)
	tween.tween_property(self, "scale",  Vector2(0, 1), 0.4)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(queue_free)

