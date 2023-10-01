extends Node
class_name Order

var order_resource: OrderResource
@export var time_left: float
@export var platform: String
@export var time: int
@export var reward: int
@export var penalty: int
@export var boxes: Array[int]

signal update_order(order: Order)
signal complete_order(order: Order)
signal fail_order(order: Order)

func update():
	emit_signal("update_order", self)

func fail():
	emit_signal("fail_order", self)

func complete():
	emit_signal("complete_order", self)
