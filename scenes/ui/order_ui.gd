extends CanvasLayer
@export var order_packed: PackedScene
@onready var orders = %Orders

func add_order(order: Order):
	var order_scene = order_packed.instantiate()
	orders.add_child(order_scene)
	order_scene.setup(order)
	
