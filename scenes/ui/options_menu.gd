extends CanvasLayer

@onready var window_button: Button = %WindowModeButton
@onready var back_button: Button = %BackButton

signal back_pressed

func _ready():
	window_button.pressed.connect(on_window_mode_button_pressed)
	back_button.pressed.connect(on_back_button_pressed)
	update_display()
	
func on_back_button_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	emit_signal("back_pressed")

func update_display():
	
	window_button.text = "Windowed"

	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		window_button.text = "Fullscreen"

func get_bus_volume_percent():
	pass

func on_window_mode_button_pressed():
	var mode = DisplayServer.window_get_mode()
	if mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	update_display()
