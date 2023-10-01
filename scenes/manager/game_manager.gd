extends Node

var current_rewards: int = 0
var current_rating: int = 1000
var current_score_mod: int = 1

@export var order_manager: OrderManager
@export var progress_ui: Node
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
	GameEvents.on_failure.connect(on_failure)
	GameEvents.score_mode_upgrade.connect(on_score_mode_upgrade)
	reset_progress.call_deferred()
	

func reset_progress():
	progress_ui.set_rating(current_rating / 1000.0)
	progress_ui.set_score(0)

func on_score_mode_upgrade(new_value):
	current_score_mod = new_value



func on_order_completed(order: Order):
	current_rewards += order.reward * current_score_mod
	current_rating += order.reward
	if current_rating > 1000:
		current_rating = 1000
	progress_ui.set_rating(current_rating / 1000.0)
	progress_ui.set_score(current_rewards)


func on_order_failed(order: Order):
	current_rating -= order.penalty
	progress_ui.set_rating(current_rating / 1000.0)
	if current_rating <= 0:
		GameEvents.emit_failure()

func on_failure():
	emit_signal("game_over")
	print("Game over")
	var screen = end_game_screen_scene.instantiate()
	screen.set_score(current_rewards)
	add_child(screen)
