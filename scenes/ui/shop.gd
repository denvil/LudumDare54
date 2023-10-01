extends CanvasLayer

var shop_manager: ShopManager
@export var power_up_scene: PackedScene
var power_ups

func _ready():
	get_tree().paused = true

func setup(manager):
	shop_manager = manager
	var speed = power_up_scene.instantiate()
	%Row1.add_child(speed)	
	speed.upgrade_button_pressed.connect(on_upgrade_button_pressed.bind("power"))
	speed.powerup = "power"

	var reverse = power_up_scene.instantiate()
	%Row1.add_child(reverse)	
	reverse.upgrade_button_pressed.connect(on_upgrade_button_pressed.bind("reverse"))
	reverse.powerup = "reverse"

	var score_mod = power_up_scene.instantiate()
	%Row1.add_child(score_mod)	
	score_mod.upgrade_button_pressed.connect(on_upgrade_button_pressed.bind("score_mod"))
	score_mod.powerup = "score_mod"


	var order_time_mode = power_up_scene.instantiate()
	%Row2.add_child(order_time_mode)	
	order_time_mode.upgrade_button_pressed.connect(on_upgrade_button_pressed.bind("order_time_mode"))
	order_time_mode.powerup = "order_time_mode"


	var extra_delivery = power_up_scene.instantiate()
	%Row2.add_child(extra_delivery)	
	extra_delivery.upgrade_button_pressed.connect(on_upgrade_button_pressed.bind("extra_delivery"))
	extra_delivery.powerup = "extra_delivery"
	


	update_display()

func update_display():
	# Setup children
	for child in %Row1.get_children():
		child.update_display(shop_manager)
	for child in %Row2.get_children():
		child.update_display(shop_manager)

	


func on_upgrade_button_pressed(type):
	shop_manager.upgrade(type)
	update_display()




func _on_back_button_pressed():
	get_tree().paused = false
	queue_free()
