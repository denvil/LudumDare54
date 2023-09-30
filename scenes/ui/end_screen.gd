extends CanvasLayer

func _ready():
	get_tree().paused = true
	%Restart.pressed.connect(on_restart_button_pressed)
	%Quit.pressed.connect(on_quit_button_pressed)
	
func on_restart_button_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
	
func on_quit_button_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
