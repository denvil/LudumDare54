extends CharacterBody2D

# Forklift variables
var wheel_base = 30  # Distance between front and rear wheels
var steering_angle = 30  # Maximum steering angle in degrees

var steer_direction
var power: float = 300
var acceleration = Vector2.ZERO

var friction = -55
var drag = -0.1

var braking = -450
var max_speed_reverse = 100

@onready var pickup_area = $PickupArea


var in_action = false
var picked_up_box = null

func get_input():
	var turn = Input.get_axis("move_left", "move_right")
	steer_direction = turn * deg_to_rad(steering_angle)
	if Input.is_action_pressed("move_up"):
		acceleration = transform.x * power
	if Input.is_action_pressed("move_down"):
		acceleration = transform.x * braking


func calculate_steering(delta):
	
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	
	var new_heading = rear_wheel.direction_to(front_wheel)
	# Check are we moving forward or backward
	if new_heading.dot(velocity) > 0:
		velocity = new_heading * velocity.length()
	else:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()


func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += friction_force + drag_force

func _physics_process(delta):
	# Process input and calculate car movement
	acceleration = Vector2.ZERO
	if not in_action:
		get_input()
		apply_friction(delta)
		calculate_steering(delta)
		velocity += acceleration * delta
	move_and_slide()


func on_picked_up():
	in_action = false
	# Remove connection
	picked_up_box.picked_up.disconnect(on_picked_up)

func on_dropped(box):
	in_action = false
	# Remove connection
	box.dropped.disconnect(on_dropped)


func pickup_box():
	# Wait for the animation to finish and then enable movement
	# First stop player
	velocity = Vector2.ZERO
	in_action = true

	if picked_up_box != null:
		picked_up_box.drop()
		picked_up_box.dropped.connect(on_dropped)
		picked_up_box = null
		$CollisionShape2D.shape.size = Vector2(39, 45)
		return
	var body = pickup_area.get_overlapping_bodies()
	if body.size() > 0:
		var box = body[0]
		box.pickup()
		picked_up_box = box
		picked_up_box.picked_up.connect(on_picked_up)
		$CollisionShape2D.shape.size = Vector2(100, 45)
		#var new_collider = RectangleShape2D.new()
		#new_collider.size = Vector2(48,45)
		#$CollisionShape2D.shape = new_collider
		
		
		
		

func handle_interaction():
	if Input.is_action_just_pressed("action"):
		pickup_box()

func _process(delta):
	handle_interaction()
