extends CharacterBody2D

var direction : float
var speed : int = 100
@onready var raycast: RayCast2D = $RayCast2D

var input_vector : Vector2
var fall_gravity : int = 4000
var gravity : int = 3000

var JUMP_VELOCITY : int = -800
var acceleration : int = 300
var push_offed : bool = false:
	set(value):
		if value:
			push_off(true)
		else:
			push_off(false)
		push_offed = value
var push_off_direction  = 1
var kick_speed_duration : int = 200
var jump_buffer_time = 0.2


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _process(delta: float) -> void:

	if direction:
		push_off_direction = direction

	direction = Input.get_axis("left","right")
	
	if direction:
		if !push_offed:
			velocity.x = move_toward(velocity.x, speed * direction, delta * acceleration)
		else:
			velocity.x = move_toward(velocity.x, speed * direction, delta * acceleration * 2)
	else:
		if !push_offed:
			velocity.x = move_toward(velocity.x, 0, delta * acceleration)
		else:
			if direction:
				velocity.x = move_toward(velocity.x, speed * push_off_direction, delta * acceleration * 2)
			else:
				velocity.x = move_toward(velocity.x, 0, delta * acceleration)
		
	velocity.y += delta * _get_gravity()

	
	if not is_on_floor() and velocity.x != 0:
		if velocity.x > 300:
			rotation_degrees = lerpf(rotation_degrees, 270, delta/10)
		else:
			if velocity.x < -300:
				rotation_degrees = lerpf(rotation_degrees, -270, delta/10)

	move_and_slide()
	

	if raycast.is_colliding() and is_on_floor():
		var surface_normal = raycast.get_collision_normal()
		var desired_rotation = surface_normal.angle() + deg_to_rad(90)  # Rotate to align with the floor

		rotation = desired_rotation
		
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY


			
	if Input.is_action_just_released("up") and velocity.y < 0:
		velocity.y = JUMP_VELOCITY / 4

	if velocity.x < 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = false
		
	if Input.is_action_just_pressed("sprint") and is_on_floor():
		push_offed = true

	
	if kick_speed_duration == 0:
		push_offed = false
		
	if push_offed:
		kick_speed_duration -= delta
	else:
		kick_speed_duration = 200
	

func push_off(i):
	if i:
		speed += 300
	else:
		speed = 100

	
func _get_gravity() -> float:
	if velocity.y < 0:
		return gravity
	return fall_gravity
