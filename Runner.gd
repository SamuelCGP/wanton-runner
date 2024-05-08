class_name Runner
extends KinematicBody2D

onready var is_wanton: bool = get_parent().is_wanton
onready var sprite = get_node("Icon")
const wanton_color := "ff0000"
const runner_color := "22b14c"

onready var speed: int = get_parent().speed
const GRAVITY: int = 50
var cur_speed: int
var is_dead = false

const CAR_TEXTURE = preload("res://textures/car.png")
const RUNNER_TEXTURE = preload("res://textures/runner.png")
const CAR_SPEED = 20
var car_pickup_tweak = 1
var is_car = false

onready var ANIMATION_VELOCITY = range_lerp(speed, 2, 10, 0.1, 0.5)
const DEGREES_ANIMATION = 15
var rotating_to = 1
var facing = 1

onready var raycast_right = get_node("RayCastRight")
onready var raycast_left = get_node("RayCastLeft")
var facing_has_changed = false

onready var step_left = get_node("step_left")
onready var step_right = get_node("step_right")
onready var car_sp = get_node("car")

onready var globals = get_node("/root/GlobalVariables")

func _ready() -> void:
	if is_wanton:
		set_modulate(Color(wanton_color))
	else:
		set_modulate(Color(runner_color))
		
	# sets speed
	cur_speed = speed
		
	# starts "animation"
	sprite.rotation_degrees = DEGREES_ANIMATION

func _physics_process(delta: float) -> void:
	# dies if it is dead
	if is_dead:
		if is_wanton:
			globals.is_wanton_dead = true
		queue_free()
		
	# transform into a car
	if is_car:
		if cur_speed != CAR_SPEED:
			car_pickup_tweak = -1
			car_sp.play()
		else:
			car_pickup_tweak = 1
			
		cur_speed = CAR_SPEED
		ANIMATION_VELOCITY = range_lerp(cur_speed, 2, 10, 0.1, 0.5)
		sprite.texture = CAR_TEXTURE
		if !is_on_floor() && car_pickup_tweak != -1:
			is_car = false
			car_sp.stop()
	else:
		cur_speed = speed
		ANIMATION_VELOCITY = range_lerp(cur_speed, 2, 10, 0.1, 0.5)
		sprite.texture = RUNNER_TEXTURE
	
	# updates the facing
	if is_on_wall():
		facing = -facing
	
	# chases the money bag
	chase_money_bag()
	
	# calculates the velocity
	var x_velocity = cur_speed * 10 * facing
	var y_velocity = GRAVITY + ((1 - car_pickup_tweak) * 10000)
	
	# effectuates the movement
	move_and_slide(Vector2(x_velocity, y_velocity), Vector2.UP)
	
	# ------------- #
	#  "animation"  #
	# ------------- #
	
	# flips the runner to face the correct direction
	if facing == 1:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
		
	# if it is as car, it will not run
	if is_car:
		sprite.rotation_degrees = 0
		return
		
	# if it is not on the floor, it will not try to "run"
	if !is_on_floor():
		return
	
	# little "running" animation
	if rotating_to == 1:
		if round(sprite.rotation_degrees) == DEGREES_ANIMATION:
			rotating_to = -1
			if(is_wanton):
				step_right.play()
			return
		sprite.rotation_degrees = lerp(sprite.rotation_degrees, DEGREES_ANIMATION, ANIMATION_VELOCITY)
	elif rotating_to == -1:
		if round(sprite.rotation_degrees) == -DEGREES_ANIMATION:
			rotating_to = 1
			if(is_wanton):
				step_left.play()
			return
		sprite.rotation_degrees = lerp(sprite.rotation_degrees, -DEGREES_ANIMATION, ANIMATION_VELOCITY)

func chase_money_bag() -> void:
	if (raycast_right.is_colliding() && !is_wanton) || (raycast_left.is_colliding() && !is_wanton):
		var is_right_side: bool = raycast_right.is_colliding()
		var body
		if is_right_side:
			body = raycast_right.get_collider()
		else:
			body = raycast_left.get_collider()
			
		# checks if the instace is valid
		if !is_instance_valid(body):
			return
		
		# checks if the body is a money bag
		if "type" in body:
			if body.type != "MoneyBag":
				return
				
		# gets the distance from raycast origin to the collision point
		var raycast_origin
		var collision_point
		if is_right_side:
			raycast_origin = raycast_right.global_transform.origin
			collision_point = raycast_right.get_collision_point()
		else:
			raycast_origin = raycast_left.global_transform.origin
			collision_point = raycast_left.get_collision_point()
		var distance = raycast_origin.distance_to(collision_point)
		
		# behaviour
			# right side
		if is_right_side:
			if(distance == 0):
				cur_speed = 0
				body.activate()
			if facing != 1:
				facing = 1
				facing_has_changed = true
			return
			# left side
		if(distance <= 10):
			cur_speed = 0
			body.activate()
		if facing != -1:
			facing = -1
			facing_has_changed = true
