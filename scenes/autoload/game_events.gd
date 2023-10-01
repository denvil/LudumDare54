extends Node

signal on_failure
signal power_upgrade(power: int)
signal reverse_upgrade(power: int)
signal score_mode_upgrade(power: int)
signal extra_delivery_upgrade(power: int)
signal order_time_mod_upgrade(power: int)
signal pressed_action

func emit_failure():
	on_failure.emit()

func emit_new_power(power: int):
	power_upgrade.emit(power)

func emit_new_reverse(power: int):
	reverse_upgrade.emit(power)
	
func emit_new_score_mod(power: int):
	score_mode_upgrade.emit(power)
	
func emit_new_order_time_mode(power: int):
	order_time_mod_upgrade.emit(power)
	
func emit_new_extra_delivery(power: int):
	extra_delivery_upgrade.emit(power)

func emit_pressed_action():
	pressed_action.emit()
