class_name WeightedTable
# Items are stored in array with their weights

var items: Array[Dictionary] = []
var current_full_weight: int = 0

func add_item(item, weight: int):
	items.append({"item": item, "weight": weight})
	current_full_weight += weight

func remote_item(item_to_remove):
	# Filter item away from items
	items = items.filter(func (item): return item["item"] != item_to_remove)
	# Recalculate current_full_weight
	current_full_weight = 0
	for item in items:
		current_full_weight += item["weight"]


func get_item():
	var random_number = randi() % current_full_weight
	var current_weight = 0
	for item in items:
		current_weight += item["weight"]
		if random_number <= current_weight:
			return item["item"]
	return null
