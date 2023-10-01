extends CanvasLayer
@onready var panel_container = %PanelContainer
var options_menu_scene = preload("res://scenes/ui/options_menu.tscn")
var is_closing = false

func _ready():
	get_tree().paused = true
	
	panel_container.pivot_offset = panel_container.size / 2
	
	$AnimationPlayer.play("default")
	
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel_container, "scale", Vector2.ONE, .3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	%ContinueButton.pressed.connect(on_continue_pressed)
	%OptionsButton.pressed.connect(on_options_pressed)
	%QuitButton.pressed.connect(on_quit_pressed)

func on_continue_pressed():
	close()

func on_options_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	var options_menu_instance = options_menu_scene.instantiate()
	add_child(options_menu_instance)
	options_menu_instance.back_pressed.connect(on_options_back_pressed.bind(options_menu_instance))

func on_options_back_pressed(options_menu: Node):
	options_menu.queue_free()

func on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func close():
	if is_closing:
		return
	$AnimationPlayer.play_backwards("default")
	is_closing = true
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0)
	tween.tween_property(panel_container, "scale", Vector2.ZERO, .3)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	
	await tween.finished
	get_tree().paused = false
	queue_free()

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		
		close()
		get_tree().root.set_input_as_handled()


func _on_powerslider_value_changed(value):
	%PowerLabel.text = "Power debug " + str(value)
	GameEvents.emit_new_power(value)
