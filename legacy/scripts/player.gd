extends CharacterBody2D
class_name Player
var direction : float
var speed : int = 100:
	set(value):
		value = clamp(value, 0, 1800)
		speed = value
@onready var raycast: RayCast2D = $RayCast2D
@onready var marker_2d: Marker2D = $Marker2D
var held_items : Array[FoodData]
const MEAL = preload("res://scenes/meal.tscn")
var turning : bool = false
var doing_trick : bool = false
var wall_bounce_timer_started : bool = false
var is_grounded : bool
var input_frame : bool
var current_throw : String = "Bullet"
var input_vector : Vector2
var fall_gravity : int = 4000
var gravity : int = 3000
var wall_jumping : bool = false
var throwing : bool = false
var holding_meal : bool
var JUMP_VELOCITY : int = -900
var acceleration : int = 400
var jump_buffer : bool
var jumping : bool
var max_timeslow_duration : int = 80
var current_timeslow_duration : float:
	set(value):
		current_timeslow_duration = clamp(value, 0, max_timeslow_duration)
var timeslow_effect : bool
var push_offed : bool = false:
	set(value):
		if value:
			push_off(true)
		else:
			push_off(false)
		push_offed = value
var push_off_direction  = 1
var kick_speed_duration : float = 100
var jump_buffer_time = 0.2
var wall_jump_direction : int
@onready var wall_jump: RayCast2D = $WallJump
var ground_pounding : bool = false
var facing : int
var grinding : bool
var grayscale_amount : float = 0
var current_trick
var check_for_rail : bool = false
var just_ground_pounded : bool:
	set(value):
		
		if value == true:
			just_ground_pounded = value
			await get_tree().create_timer(0.2).timeout
			just_ground_pounded = false
var wall_bounce_floor_check : bool

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D2


func update_position():
	$AnimatedSprite2D.global_position = global_position
	$AnimatedSprite2D.global_rotation_degrees = global_rotation_degrees
	$CollisionShape2D.global_rotation_degrees = 0
	$WallRight.global_rotation_degrees = 0
	$WallRightReal.global_rotation_degrees = 0
	$WallLeft.global_rotation_degrees = 0
	$WallLeftReal.global_rotation_degrees = 0
	$WallJump.global_rotation_degrees = 0
	$RailCast.global_rotation_degrees = 0
	
	
	var tween = get_tree().create_tween()
	if jumping:
		tween.tween_property($AnimatedSprite2D, "global_position:y", global_position.y + 5, 0.02)
	else:
		tween.tween_property($AnimatedSprite2D, "global_position:y", global_position.y, 0.05)

func _process(delta: float) -> void:
	grind()
	
	if Input.is_action_just_pressed("grind") and velocity.x != 0:
		print("E")
		check_for_rail = true
		$RailCast.set_collision_mask_value(4, true)
		set_collision_layer_value(4, true)
		set_collision_mask_value(4, true)
		
		await get_tree().create_timer(0.3).timeout
		
		if !grinding:
			check_for_rail = false

	if !check_for_rail:
			$RailCast.set_collision_mask_value(4, false)
			set_collision_layer_value(4, false)
			set_collision_mask_value(4, false)
		
	if animated_sprite_2d.flip_h == false:
		facing = 1
	else:
		facing = -1
	
	if wall_jumping and is_on_floor():
		wall_jumping = false
	#wall_jump.target_position.x = 15 * facing
	
	if Input.is_action_just_pressed("time slow"):
		timeslow_effect = not timeslow_effect
	
	
	
	if timeslow_effect and current_timeslow_duration > 0:
		Engine.time_scale = move_toward(Engine.time_scale, 0.2, delta * 4)
		grayscale_amount = move_toward(grayscale_amount, 1, delta * 4)
		$"../CanvasLayer/ColorRect".material.set_shader_parameter("grayscale_amount", grayscale_amount)

		current_timeslow_duration -= 0.2
		
	else:
		grayscale_amount = move_toward(grayscale_amount, 0, delta * 4)
		Engine.time_scale = move_toward(Engine.time_scale, 1, delta * 4)
		current_timeslow_duration += 0.1
		$"../CanvasLayer/ColorRect".material.set_shader_parameter("grayscale_amount", grayscale_amount)
	
	if current_timeslow_duration <= 0:
		timeslow_effect = false
		
		

	
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
	

	$Label.text = str(held_items)
	if !Input.is_action_pressed("throw"):
		$Line2D.hide()
		throwing = false
	else:
		if holding_meal:
			$Line2D.show()
			throwing = true
	if Input.is_action_just_pressed("ground_pound") and is_on_floor() == false and !ground_pounding:
		ground_pounding = true
	if ground_pounding:
		velocity.x = move_toward(velocity.x, 0, delta * 2000)
		velocity.y += 5000 * delta
		if speed > 300:
			speed = 800
	if is_on_floor():
		if ground_pounding:
			just_ground_pounded = true
		ground_pounding = false
		
	
	velocity.x = clamp(velocity.x, -1800, 1800)
	
	if direction:
		
		push_off_direction = direction
	if !grinding:
		direction = Input.get_axis("left","right")
	

		
	if direction or doing_trick:
		velocity.x = move_toward(velocity.x, speed * direction, delta * acceleration)

	else:
		velocity.x = move_toward(velocity.x, 0, delta * acceleration)


	velocity.y += delta * _get_gravity()
	if direction and !turning:
		if !grinding and is_on_floor():
			kick_speed_duration -= Engine.time_scale
			if kick_speed_duration <= 0:
				if (velocity.x >= -1000 and velocity.x < 1000):
					kick_speed_duration = 100
				push_offed = true
	else:
		if !doing_trick:
			push_offed = false
			
	if kick_speed_duration <= 0:
		if !(velocity.x >= -1000 and velocity.x < 1000):
			kick_speed_duration = 0

	if direction != sign(velocity.x) and direction != 0 and is_on_floor() and velocity.x != 0:
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
		if Input.is_action_just_released("throw"):
			var meal = marker_2d.get_child(0)
			
			meal.get_node("GrabbableComponent").put_down()
			meal.throw(global_position, get_global_mouse_position(), current_throw)
			
	else:
		holding_meal = false
	move_and_slide()
	

	if Input.is_action_just_pressed("grind") and ($WallRight.is_colliding() or $WallLeft.is_colliding()) and velocity.x != 0 and !wall_jumping:
		
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
			velocity.x = -sign(velocity.x) * 1000
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
		var desired_rotation = surface_normal.angle() + deg_to_rad(90)  

		

		rotation = desired_rotation
		#if raycast.get_collider().is_in_group("grind") and !doing_trick:
			#if Input.is_action_pressed("grind") and direction:
				#grind()
	#elif raycast.is_colliding() and !is_on_floor():
		#if raycast.get_collider().is_in_group("grind") and !doing_trick:
			#grind()
	#else:
		#grinding = false

	if Input.is_action_just_pressed("jump"):
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
		
	get_trajectory(get_global_mouse_position(), 10, delta)


	if held_items.size() > 0 and marker_2d.get_child_count() == 0:
		var meal_ins = MEAL.instantiate()
		meal_ins.data = held_items[0]
		marker_2d.add_child(meal_ins)
		
func push_off(i):
	
	if (speed >= -1000 and speed < 1000):
		
		if i:
			speed += 350
			if not (speed >= -1000 and speed < 1000):
				speed = clamp(speed, -1000, 1000)
		else:
			if wall_jumping == false and !grinding:
				speed = 250

	
func _get_gravity() -> float:
	if wall_jump.is_colliding() == false:
		if velocity.y < 0:
			return gravity
		return fall_gravity
	if velocity.y > 0:
		return 500
	else:
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
		if just_ground_pounded:
			velocity.y = JUMP_VELOCITY * 1.5
		await get_tree().process_frame
		jumping = true
	
	elif !is_on_floor():
		jump_buffer = true
		await get_tree().create_timer(0.1).timeout
		jump_buffer = false
		if wall_jump.is_colliding():
			if !wall_jumping:
				if animated_sprite_2d.flip_h == false:
					wall_jump_direction = -1
				else:
					wall_jump_direction = 1
				wall_jumping = true
				velocity.x = wall_jump_direction * 700
				speed = 800
				velocity.y = JUMP_VELOCITY * 1.2
				await get_tree().process_frame
				jumping = true
			else:
				wall_jumping = true
				wall_jump_direction = wall_jump_direction * -1
				velocity.x = wall_jump_direction * 700
				
				speed = 800
				velocity.y = JUMP_VELOCITY * 1.2
				await get_tree().process_frame
				jumping = true
func on_wall_bounce_timeout():
	if wall_bounce_timer_started:
		doing_trick = false
	wall_bounce_timer_started = false

func grind():
	#if Input.is_action_pressed("grind") and direction:
		#if velocity.x != 0:
			#grinding = true
			#if (speed >= -1350 and speed < 1350):
				#if velocity.x > 0 and raycast.get_collider().rotation_degrees == 0:
					#speed += 14
				#elif velocity.x < 0 and raycast.get_collider().rotation_degrees == 0:
					#speed += 14
				#elif raycast.get_collider().rotation_degrees != 0 and velocity.x == 0:
					#position.y += 1
					#
				#else:
					#if velocity.x > 0 and raycast.get_collider().rotation_degrees > 0:
						#speed += 25
					#elif velocity.x < 0 and raycast.get_collider().rotation_degrees < 0:
						#speed += 25
#
					#else:
						#speed = move_toward(speed, 0, 1)
		#else:
			#grinding = false
			#position.y += 3
	#else:
		#grinding = false
		#position.y += 3
		#
	if $RailCast.is_colliding() and check_for_rail:
		if $RailCast.get_collider().is_in_group("grind") and velocity.x != 0:
			
			grinding = true
			rotation_degrees = $RailCast.get_collider().rotation_degrees
			speed += 4
			velocity.x = sign(velocity.x) * speed
		else:
			if grinding:
				check_for_rail = false
			grinding = false
	else:
		if grinding:
			check_for_rail = false
		grinding = false
		
func get_trajectory(end_point: Vector2, line_speed: float, delta):
	if current_throw == "Arc":
		$Line2D.clear_points()
		var base_arc_height = 100
		var arc_height_factor: float = 0.5
		var local_start = to_local(global_position)
		var local_end = to_local(end_point)

		# Calculate the distance between start and end points
		var distance = local_start.distance_to(local_end)
		
		# Calculate the dynamic height of the arc based on distance
		var arc_height = base_arc_height / (distance / 100 + 1)  # Adjust denominator for smoother scaling

		var mid_point = (local_start + local_end) / 2
		mid_point.y -= arc_height  # Increase arc height as distance decreases

		$Line2D.clear_points()
		var points = calculate_bezier_points(local_start, mid_point, local_end)
		
		for point in points:
			$Line2D.add_point(point)
	else:
		var start_point = position
		var bullet_end_point = get_local_mouse_position()
		$Line2D.points = [Vector2.ZERO, bullet_end_point]
	if Input.is_action_just_pressed("switch_throw"):
		match current_throw:
			"Bullet":
				current_throw = "Arc"
			"Arc":
				current_throw = "Bullet"
func calculate_bezier_points(p0: Vector2, p1: Vector2, p2: Vector2) -> Array:
	var points = []
	var num_segments = 30
	
	for t in range(num_segments + 1):
		var progress = t / float(num_segments)
		var point = (1 - progress) * (1 - progress) * p0 + 2 * (1 - progress) * progress * p1 + progress * progress * p2
		points.append(point)
	
	return points
