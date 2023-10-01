extends CharacterBody2D

# Forklift variables
var wheel_base = 30  # Distance between front and rear wheels
var steering_angle = 30  # Maximum steering angle in degrees

var steer_direction
var acceleration = Vector2.ZERO

var friction = -55
var drag = -0.1

var braking = -450
var max_speed_reverse = 100
@onready var visuals = %Visuals
@onready var brrr_sound = $brrrSound
@onready var lift = $lift

@onready var pickup_area = $PickupArea
@export var trail_scene: PackedScene

var slip_speed = 150 # Go over and slip slide will start
var traction_fast = 2.5
var traction_slow = 10

var in_action = false
var picked_up_box = null

var current_trail = null

var base_power: int = 300


func _ready():
	GameEvents.power_upgrade.connect(on_power_upgrade)
	GameEvents.reverse_upgrade.connect(on_reverse_upgrade)

func on_reverse_upgrade(new_power):
	max_speed_reverse = new_power

func on_power_upgrade(new_power):
	base_power = new_power

func get_input():
	var turn = Input.get_axis("move_left", "move_right")
	steer_direction = turn * deg_to_rad(steering_angle)
	if Input.is_action_pressed("move_up"):
		acceleration = transform.x * get_power()
	if Input.is_action_pressed("move_down"):
		acceleration = transform.x * braking


func get_power():
	if picked_up_box == null:
		return base_power
	else:
		return base_power * 0.5
		
func get_max_reverse():
	if picked_up_box == null:
		return max_speed_reverse
	else:
		return max_speed_reverse * 0.7

func calculate_steering(delta):
	
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	# choose which traction value to use - at lower speeds, slip should be low
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
		if current_trail == null:
			start_trail()
	else:
		if current_trail != null:
			stop_trail()
	brrr_sound.pitch_scale = remap(velocity.length(),0, 300, 0.6, 1.4)
	# Check are we moving forward or backward
	if new_heading.dot(velocity) > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
	else:
		velocity = -new_heading * min(velocity.length(), get_max_reverse())
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



	if picked_up_box != null:
		lift.play()
		# First stop player
		velocity = Vector2.ZERO
		in_action = true
		picked_up_box.drop()
		picked_up_box.dropped.connect(on_dropped)
		picked_up_box = null
		$CollisionShape2D.shape.size = Vector2(31, 30)
		$CollisionShape2D.position.x = -9.5
		return
	var body = pickup_area.get_overlapping_bodies()
	if body.size() > 0:
		lift.play()
		# First stop player
		velocity = Vector2.ZERO
		in_action = true
		var box = body[0]
		box.pickup()
		picked_up_box = box
		picked_up_box.picked_up.connect(on_picked_up)
		$CollisionShape2D.shape.size = Vector2(57, 30)
		$CollisionShape2D.position.x = 6

	# Just use game events as jam is closing..
	if picked_up_box == null:
		GameEvents.emit_pressed_action()


func handle_interaction():
	if Input.is_action_just_pressed("action"):
		pickup_box()

func _process(_delta):
	handle_interaction()

func start_trail():
	if current_trail != null:
		return
	current_trail = trail_scene.instantiate() as Node2D
	visuals.add_child(current_trail)
	current_trail.global_position = self.global_position
	current_trail.global_rotation = self.global_rotation
	
func stop_trail():
	if current_trail == null:
		return
	current_trail.start_fade()
	current_trail = null
