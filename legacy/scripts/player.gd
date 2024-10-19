extends CharacterBody2D
class_name Player
var direction : float
var speed : int = 100:
	set(value):
		value = clamp(value, 0, 1800)
		speed = value
@onready var raycast: RayCast2D = $RayCast2D
@onready var marker_2d: Marker2D = $Marker2D

var turning : bool = false
var doing_trick : bool = false
var wall_bounce_timer_started : bool = false
var is_grounded : bool
var input_frame : bool
var input_vector : Vector2
var fall_gravity : int = 4000
var gravity : int = 3000
var holding_meal : bool
var JUMP_VELOCITY : int = -900
var acceleration : int = 400
var jump_buffer : bool
var jumping : bool
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
var current_trick
var wall_bounce_floor_check : bool
signal grounded_updated(is_grounded)
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D2
func update_position():
	$AnimatedSprite2D.global_position = global_position
	$AnimatedSprite2D.global_rotation_degrees = global_rotation_degrees
	var tween = get_tree().create_tween()
	if jumping:
		tween.tween_property($AnimatedSprite2D, "global_position:y", global_position.y + 5, 0.02)
	else:
		tween.tween_property($AnimatedSprite2D, "global_position:y", global_position.y, 0.05)

func _process(delta: float) -> void:
	if !doing_trick and current_trick:

		current_trick = null
	call_deferred("update_position")
	if jumping and is_on_floor() and velocity.y == 0:
		jumping = false

	$AnimatedSprite2D.global_position = global_position
	$AnimatedSprite2D.global_rotation_degrees = global_rotation_degrees
	if jumping:
		$AnimatedSprite2D.global_position.y = move_toward($AnimatedSprite2D.global_position.y, global_position.y + 5, 20)
	else:
		$AnimatedSprite2D.global_position.y = move_toward($AnimatedSprite2D.global_position.y, global_position.y, 20)
	if velocity.x < 0:
		$AnimatedSprite2D2.flip_h = true
		$AnimatedSprite2D.flip_h = true
	if  velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D2.flip_h = false
	
	$Label.text = str($"../UI".backed_up_orders)
	
	velocity.x = clamp(velocity.x, -1800, 1800)
	
	if direction:
		
		push_off_direction = direction

	direction = Input.get_axis("left","right")
	
	if holding_meal and Input.is_action_just_pressed("grind"):

		marker_2d.get_child(0).get_child(0).linear_velocity = Vector2(direction * 1000, 0)
		InteractionManager.currently_holding_item = false
		marker_2d.get_child(0).put_down()
		
	if direction or doing_trick:
		velocity.x = move_toward(velocity.x, speed * direction, delta * acceleration)

	else:
		velocity.x = move_toward(velocity.x, 0, delta * acceleration)


	velocity.y += delta * _get_gravity()
	if direction and !turning:
		if !grinding and is_on_floor():
			kick_speed_duration -= delta
			if kick_speed_duration <= 0:
				if (velocity.x >= -1000 and velocity.x < 1000):
					kick_speed_duration = 100
				push_offed = true
	else:
		if !doing_trick:
			push_offed = false


	if direction != (velocity.x / abs(velocity.x)) and direction != 0 and is_on_floor() and velocity.x != 0:
		speed = 100
		turning = true
		if direction == 1:
			velocity.x += 1
			$GPUParticles2D.emitting = true
			$GPUParticles2D2.emitting = false
		elif direction == -1:
			
			velocity.x -= 1
			$GPUParticles2D.emitting = false
			$GPUParticles2D2.emitting = true
			
	else:
		$GPUParticles2D.emitting = false
		$GPUParticles2D2.emitting = false
		turning = false
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
	
	var was_grounded = is_grounded 
	is_grounded = is_on_floor()
	if was_grounded == null or is_grounded != was_grounded:
		grounded_updated.emit(is_grounded)
	if Input.is_action_just_pressed("grind") and ($WallRight.is_colliding() or $WallLeft.is_colliding()) and velocity.x != 0:
		
		if velocity.x > 0:
			if velocity.x > 200:
				doing_trick = true
				current_trick = "wallbounce"
				wall_bounce_timer_started = true
				get_tree().create_timer(0.5).timeout.connect(on_wall_bounce_timeout)
		else:
			if velocity.x < 200:
				doing_trick = true
				current_trick = "wallbounce"
				wall_bounce_timer_started = true
				get_tree().create_timer(0.5).timeout.connect(on_wall_bounce_timeout)

			
	if current_trick == "wallbounce":
		if wall_bounce_timer_started and (is_on_wall() or ($WallRightReal.is_colliding() or $WallLeftReal.is_colliding())):
			
			wall_bounce_timer_started = false
			velocity.y = -700
			velocity.x = -(abs(velocity.x)/velocity.x) * 1000
			speed += 900
			kick_speed_duration = 100
			push_offed = true
			wall_bounce_floor_check = true
			
	if wall_bounce_floor_check and is_on_floor() and velocity.y == 0:
		Global.tricks_done += 1
		speed += 900
		wall_bounce_floor_check = false

	if current_trick == "wallbounce" and is_on_floor() and !wall_bounce_timer_started:
		doing_trick = false
	if raycast.is_colliding() and is_on_floor():
		var surface_normal = raycast.get_collision_normal()
		var desired_rotation = surface_normal.angle() + deg_to_rad(90)  # Rotate to align with the floor

		

		rotation = desired_rotation
		if raycast.get_collider().is_in_group("grind") and !doing_trick:
			if Input.is_action_pressed("grind") and direction:
				if velocity.x != 0:
					grinding = true
					if (speed >= -1350 and speed < 1350):
						if velocity.x > 0 and raycast.get_collider().rotation_degrees == 0:
							speed += 14
						elif velocity.x < 0 and raycast.get_collider().rotation_degrees == 0:
							speed += 14
						elif raycast.get_collider().rotation_degrees != 0 and velocity.x == 0:
							position.y += 1
							
						else:
							if velocity.x > 0 and raycast.get_collider().rotation_degrees > 0:
								speed += 25
							elif velocity.x < 0 and raycast.get_collider().rotation_degrees < 0:
								speed += 25

							else:
								speed = move_toward(speed, 0, 1)
				else:
					grinding = false
					position.y += 3
			else:
				grinding = false
				position.y += 3
	elif raycast.is_colliding() and !is_on_floor():
		if raycast.get_collider().is_in_group("grind") and !doing_trick:
			if Input.is_action_pressed("grind") and direction:
				if velocity.x != 0:
					grinding = true
					if (speed >= -1350 and speed < 1350):
						if velocity.x > 0 and raycast.get_collider().rotation_degrees == 0:
							speed += 14
						elif velocity.x < 0 and raycast.get_collider().rotation_degrees == 0:
							speed += 14
						elif raycast.get_collider().rotation_degrees != 0 and velocity.x == 0:
							position.y += 3
							
						else:
							if velocity.x > 0 and raycast.get_collider().rotation_degrees > 0:
								speed += 25
							elif velocity.x < 0 and raycast.get_collider().rotation_degrees < 0:
								speed += 25
								
							else:
								speed = move_toward(speed, 0, 1)
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
		await get_tree().create_timer(0.5).timeout
		input_frame = false
	if is_on_floor() and velocity.y == 0 and current_trick == "kickflip":
		doing_trick = false
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
		


	if is_on_floor() and !doing_trick and !grinding:
		animated_sprite_2d.play("normal")
		$AnimatedSprite2D.play("normal")
	if grinding:
		animated_sprite_2d.play("grind")
		$AnimatedSprite2D.play("grind")
	if kick_speed_duration == 0:
		push_offed = false
	if doing_trick and current_trick == "kickflip" and is_on_floor() and velocity.y == 0:
		doing_trick = false



func push_off(i):
	
	if (speed >= -1000 and speed < 1000):
		
		if i:
			speed += 350
			if not (speed >= -1000 and speed < 1000):
				speed = clamp(speed, -1000, 1000)
		else:
			speed = 150

	
func _get_gravity() -> float:
	if velocity.y < 0:
		return gravity
	return fall_gravity
	
func jump():
	if is_on_floor():
		if input_frame:
			velocity.x += 400 * direction
			Global.tricks_done += 1
			animated_sprite_2d.play("kickflip")
			$AnimatedSprite2D.play("kickflip")
			doing_trick = true
			current_trick = "kickflip"
		if grinding:
			speed += 70
		velocity.y = JUMP_VELOCITY
		await get_tree().process_frame
		jumping = true


	elif !is_on_floor():
		jump_buffer = true
		await get_tree().create_timer(0.1).timeout
		jump_buffer = false
func on_wall_bounce_timeout():
	if wall_bounce_timer_started:
		doing_trick = false
	wall_bounce_timer_started = false
	#test test test
