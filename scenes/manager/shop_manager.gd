extends Node
class_name ShopManager

var shop_ui_scene = preload("res://scenes/ui/shop.tscn")

var current_inventory: Dictionary
@export var shop_player_detecter: Area2D


var power_ups: Dictionary
# Powers. Just reference this player when doing stuff. No need for fancy systems as there
# is only 8 hours left. Note also keep up on other updates here as we do not have good
# upgrade system
var power: int = 0
var reverse: int = 0
var score_mod: int = 0
var order_time_mode: int = 0
var extra_delivery: int = 0


func _ready():
	GameEvents.pressed_action.connect(on_pressed_action)
	current_inventory["0"] = 0
	current_inventory["1"] = 0
	current_inventory["2"] = 0
	power_ups = {
		"power": {
			"name": "Forward speed",
			"levels": [
				{
					"price": [1,0,0],
					"value": 400
				},
				{
					"price": [2,0,0],
					"value": 500
				},
				{
					"price": [2,1,0],
					"value": 600
				},
				{
					"price": [1,1,2],
					"value": 800
				},
				{
					"price": [1,2,2],
					"value": 1000
				},																
			]
		},
		"reverse": {
			"name": "Reverse speed",
			"levels": [
				{
					"price": [1,0,0],
					"value": 200
				},
				{
					"price": [2,0,0],
					"value": 300
				},
				{
					"price": [2,1,0],
					"value": 400
				},
				{
					"price": [1,1,2],
					"value": 500
				},
				{
					"price": [1,2,2],
					"value": 600
				},																
			]
		},
		"score_mod": {
			"name": "Extra score",
			"levels": [
				{
					"price": [1,0,0],
					"value": 2
				},
				{
					"price": [2,0,0],
					"value": 3
				},
				{
					"price": [2,1,0],
					"value": 4
				},
				{
					"price": [1,1,2],
					"value": 5
				},
				{
					"price": [1,2,2],
					"value": 6
				},																
			]
		},
		"order_time_mode": {
			"name": "Extra time for orders",
			"levels": [
				{
					"price": [1,0,0],
					"value": 10
				},
				{
					"price": [2,0,0],
					"value": 20
				},
				{
					"price": [2,1,0],
					"value": 25
				},
				{
					"price": [1,1,2],
					"value": 30
				},
				{
					"price": [1,2,2],
					"value": 35
				},																
			]
		},
		"extra_delivery": {
			"name": "Delivery size",
			"levels": [
				{
					"price": [2,0,0],
					"value": 1
				},
				{
					"price": [2,1,0],
					"value": 2
				},
				{
					"price": [1,2,0],
					"value": 3
				},
				{
					"price": [0,2,2],
					"value": 4
				},
				{
					"price": [2,1,3],
					"value": 5
				},																
			]
		}
	}
	
func get_powerup_level(power_up: String) -> int:
	if power_up == "power":
		return power
	elif power_up == "reverse":
		return reverse
	elif power_up == "score_mod":
		return score_mod
	elif power_up == "order_time_mode":
		return order_time_mode
	elif power_up == "extra_delivery":
		return extra_delivery
	else: 
		return 0

func upgrade(ability: String):
	var current_level = get_powerup_level(ability)
	var power_up_data = power_ups[ability]
	var level = power_up_data["levels"][current_level]
	var price = level["price"]
	var can_upgrade = true
	for i in range(price.size()):
		if current_inventory[str(i)] < price[i]:
			can_upgrade = false
			break
	if can_upgrade:
		for i in range(price.size()):
			current_inventory[str(i)] -= price[i]
		if ability == "power":
			GameEvents.emit_new_power(power_up_data["levels"][power]["value"])
			power += 1
		elif ability == "reverse":
			GameEvents.emit_new_reverse(power_up_data["levels"][reverse]["value"])
			reverse += 1
		elif ability == "score_mod":
			GameEvents.emit_new_score_mod(power_up_data["levels"][score_mod]["value"])
			score_mod += 1
		elif ability == "order_time_mode":
			GameEvents.emit_new_order_time_mode(power_up_data["levels"][order_time_mode]["value"])
			order_time_mode += 1
		elif ability == "extra_delivery":
			GameEvents.emit_new_extra_delivery(power_up_data["levels"][extra_delivery]["value"])
			extra_delivery += 1
		return true
	else:
		return false

func price_status(power_up: String) -> Array:
	
	var current_level = get_powerup_level(power_up)
	
	var power_up_data = power_ups[power_up]
	var level = power_up_data["levels"][current_level]
	var price = level["price"]
	var price_stat = []
	for i in range(price.size()):
		price_stat.append([price[i], current_inventory[str(i)]])
	return price_stat

func on_pressed_action():
	if shop_player_detecter.get_overlapping_bodies().size() > 0:
		var shop_ui = shop_ui_scene.instantiate()
		shop_ui.setup(self)
		add_child(shop_ui)

func _on_shop_body_entered(body):
	body.remove()
	current_inventory[str(body.box_type)] += 1
