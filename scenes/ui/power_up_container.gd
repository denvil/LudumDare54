extends PanelContainer

@export var box_scene: PackedScene
var powerup: String

signal upgrade_button_pressed


func update_display(shop_manager: ShopManager):
	if powerup == "power":
		set_title(shop_manager.power_ups["power"]["name"], shop_manager.power)
		set_pricing(shop_manager.price_status("power"), shop_manager.power)
	elif powerup == "reverse":
		set_title(shop_manager.power_ups["reverse"]["name"], shop_manager.reverse)
		set_pricing(shop_manager.price_status("reverse"), shop_manager.reverse)
	elif powerup == "score_mod":
		set_title(shop_manager.power_ups["score_mod"]["name"], shop_manager.score_mod)
		set_pricing(shop_manager.price_status("score_mod"), shop_manager.score_mod)
	elif powerup == "order_time_mode":
		set_title(shop_manager.power_ups["order_time_mode"]["name"], shop_manager.order_time_mode)
		set_pricing(shop_manager.price_status("order_time_mode"), shop_manager.order_time_mode)
	elif powerup == "extra_delivery":
		set_title(shop_manager.power_ups["extra_delivery"]["name"], shop_manager.extra_delivery)
		set_pricing(shop_manager.price_status("extra_delivery"), shop_manager.extra_delivery)

func set_title(title: String, level: int) -> void:
	if level > 4:
		%NameLabel.text = title + " MAX"
	else:
		%NameLabel.text = title + " "+str(level+1)

func set_pricing(price_status: Array, level: int):
	# Clear children of PriceContainer
	for child in %PriceContainer.get_children():
		child.fade_out()
	if level > 4:
		%PriceContainer.visible = false
		%UpgradeButton.disabled = true
		%UpgradeButton.text = "MAX"
		return 
	var can_buy = true
	# Box A
	var box_a_price = price_status[0][0]
	var box_a_status = price_status[0][1]
	for i in range(0, box_a_price):
		var box = box_scene.instantiate()
		box.set_boxtype(0)
		%PriceContainer.add_child(box)
		if box_a_status <= 0:
			box.modulate = Color.GRAY
			can_buy = false
		box_a_status -= 1
	# Box B
	var box_b_price = price_status[1][0]
	var box_b_status = price_status[1][1]
	for i in range(0, box_b_price):
		var box = box_scene.instantiate()
		box.set_boxtype(1)
		%PriceContainer.add_child(box)
		if box_b_status <= 0:
			box.modulate = Color.GRAY
			can_buy = false
		box_b_status -= 1
	# Box C
	var box_c_price = price_status[2][0]
	var box_c_status = price_status[2][1]
	for i in range(0, box_c_price):
		var box = box_scene.instantiate()
		box.set_boxtype(2)
		%PriceContainer.add_child(box)
		if box_c_status <= 0:
			box.modulate = Color.GRAY
			can_buy = false
		box_c_status -= 1	
	if can_buy:
		%UpgradeButton.disabled = false
		%UpgradeButton.text = "Upgrade"
	else:
		%UpgradeButton.disabled = true
		%UpgradeButton.text = "Not enough boxes"
	


func _on_upgrade_button_pressed():
	upgrade_button_pressed.emit()
