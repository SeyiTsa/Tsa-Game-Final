extends CharacterBody2D

var direction : float
var speed : int = 100
@onready var raycast: RayCast2D = $RayCast2D
@onready var marker_2d: Marker2D = $Marker2D

var input_frame : bool
var input_vector : Vector2
var fall_gravity : int = 4000
var gravity : int = 3000
var holding_meal : bool
var JUMP_VELOCITY : int = -800
var acceleration : int = 300
var jump_buffer : bool
var push_offed : bool = false:
	set(value):
		if value:
			push_off(true)
		else:
			push_off(false)
		push_offed = value
var push_off_direction  = 1
var kick_speed_duration : int = 100
var jump_buffer_time = 0.2
var grinding : bool

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _process(delta: float) -> void:
	if velocity.x < 0:
		$Sprite2D.flip_h = true
	if  velocity.x > 0:
		$Sprite2D.flip_h = false
	$Label.text = str(jump_buffer)
	velocity.x = clamp(velocity.x, -1800, 1800)
	if direction:
		
		push_off_direction = direction

	direction = Input.get_axis("left","right")
	
	if direction:
		if !push_offed and !grinding:
			velocity.x = move_toward(velocity.x, speed * direction, delta * acceleration)
		else:
			if !grinding:
				if (velocity.x >= -1400 and velocity.x < 1400):
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

	if direction != (velocity.x / abs(velocity.x)) and direction != 0 and is_on_floor():
		if direction == 1:
			$GPUParticles2D.emitting = true
			$GPUParticles2D2.emitting = false
		elif direction == -1:
			$GPUParticles2D.emitting = false
			$GPUParticles2D2.emitting = true
			
	else:
		$GPUParticles2D.emitting = false
		$GPUParticles2D2.emitting = false
	
	if not is_on_floor() and velocity.x != 0:
		if velocity.x > 300:
			rotation_degrees = lerpf(rotation_degrees, 180, delta/10)
		else:
			if velocity.x < -300:
				rotation_degrees = lerpf(rotation_degrees, -180, delta/10)
	if marker_2d.get_child_count() > 0:
		holding_meal = true
	else:
		holding_meal = false
	move_and_slide()
	

	if raycast.is_colliding() and is_on_floor():
		var surface_normal = raycast.get_collision_normal()
		var desired_rotation = surface_normal.angle() + deg_to_rad(90)  # Rotate to align with the floor

		rotation = desired_rotation
		if raycast.get_collider().is_in_group("grind"):
			if Input.is_action_pressed("grind") and direction:
				if velocity.x != 0:
					grinding = true
					if (velocity.x >= -1200 and velocity.x < 1200):
						if velocity.x > 0 and raycast.get_collider().rotation_degrees == 0:
							velocity.x += 7
						elif velocity.x < 0 and raycast.get_collider().rotation_degrees == 0:
							velocity.x -= 7
						elif raycast.get_collider().rotation_degrees != 0 and velocity.x == 0:
							position.y += 1
							
						else:
							if velocity.x > 0 and raycast.get_collider().rotation_degrees > 0:
								velocity.x += 20
							elif velocity.x < 0 and raycast.get_collider().rotation_degrees < 0:
								velocity.x -= 20
							else:
								velocity.x = move_toward(velocity.x, 0, 1)
				else:
					grinding = false
					position.y += 3
			else:
				grinding = false
				position.y += 3
	elif raycast.is_colliding() and !is_on_floor():
		if raycast.get_collider().is_in_group("grind"):
			if Input.is_action_pressed("grind") and direction:
				if velocity.x != 0:
					grinding = true
					if (velocity.x >= -1200 and velocity.x < 1200):
						if velocity.x > 0 and raycast.get_collider().rotation_degrees == 0:
							velocity.x += 7
						elif velocity.x < 0 and raycast.get_collider().rotation_degrees == 0:
							velocity.x -= 7
						elif raycast.get_collider().rotation_degrees != 0 and velocity.x == 0:
							position.y += 3
							
						else:
							if velocity.x > 0 and raycast.get_collider().rotation_degrees > 0:
								velocity.x += 20
							elif velocity.x < 0 and raycast.get_collider().rotation_degrees < 0:
								velocity.x -= 20
							else:
								velocity.x = move_toward(velocity.x, 0, 1)
				else:
					grinding = false
					position.y += 3
			else:
				grinding = false
				position.y += 3
	else:
		grinding = false

	if Input.is_action_just_pressed("up"):
		jump()
	if jump_buffer and is_on_floor():
		jump_buffer = false
		jump()
	if Input.is_action_just_pressed("grind"):
		input_frame = true
		await get_tree().create_timer(0.2).timeout
		input_frame = false

	if grinding:
		if velocity.x > 0:
			$Polygon2D2.show()
			$Polygon2D3.hide()
		elif velocity.x < 0:
			$Polygon2D3.show()
			$Polygon2D2.hide()
	else:
		$Polygon2D2.hide()
		$Polygon2D3.hide()
		
	if Input.is_action_pressed("grind") and velocity.x != 0:
		raycast.set_collision_mask_value(3, true)
		set_collision_mask_value(3, true)
	else:
		raycast.set_collision_mask_value(3, false)
		set_collision_mask_value(3, false)


	if velocity.x < 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = false
		
	if Input.is_action_just_pressed("push_off") and is_on_floor():
		if (velocity.x >= -1400 and velocity.x < 1400):
			kick_speed_duration = 100
		push_offed = true

	
	if kick_speed_duration == 0:
		push_offed = false
		
	if push_offed:
		kick_speed_duration -= delta
	if !push_offed and speed != 100:
		speed = 100
	

func push_off(i):
	if (velocity.x >= -1400 and velocity.x < 1400):
		if i:
			speed += 120
		else:
			speed = 100

	
func _get_gravity() -> float:
	if velocity.y < 0:
		return gravity
	return fall_gravity
	
func jump():
	if is_on_floor():
		if input_frame:
			print("e")
		if grinding:
			velocity.x += direction * 500
		velocity.y = JUMP_VELOCITY
	elif !is_on_floor():
		print("e")
		jump_buffer = true
		await get_tree().create_timer(0.1).timeout
		jump_buffer = false
