extends Node

var current_rewards: int = 0
var current_rating: int = 1

@export var order_manager: OrderManager
@export var end_game_screen_scene: PackedScene
var pause_screen_scene = preload("res://scenes/ui/pause_menu.tscn")

signal game_over

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		add_child(pause_screen_scene.instantiate())
		get_tree().root.set_input_as_handled()

func _ready():
	order_manager.order_completed.connect(on_order_completed)
	order_manager.order_failed.connect(on_order_failed)

func on_order_completed(order: Order):
	current_rewards += order.order_resource.reward
	current_rating += order.order_resource.reward
	print(current_rating)


func on_order_failed(order: Order):
	current_rating -= order.order_resource.penalty
	print(current_rating)
	if current_rating < 0:
		emit_signal("game_over")
		print("Game over")
		var screen = end_game_screen_scene.instantiate()
		add_child(screen)

