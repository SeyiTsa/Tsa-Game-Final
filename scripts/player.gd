extends CharacterBody2D

var direction : Vector2
var speed : int = 200
var sprint_speed : int = 300
var input_vector : Vector2
var holding_extinguisher : bool = false
var using_fire_extinguisher : bool = false
var item_direction : Vector2

const FIRE = preload("res://scenes/fire.tscn")
@onready var marker_2d: Marker2D = $Marker2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_tree: AnimationTree = $AnimationTree

func _process(delta: float) -> void:
	
	direction = Input.get_vector("left","right","up","down").normalized()
	
	if direction and !using_fire_extinguisher:
		velocity = velocity.move_toward(direction * get_speed(), delta * get_acceleration())
	else:
		velocity = velocity.move_toward(Vector2.ZERO, delta * get_acceleration())

	move_and_slide()
	
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	if using_fire_extinguisher:
		input_vector = Vector2.ZERO
	if velocity.x < 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = false
	if marker_2d.get_child_count() > 0:
		if marker_2d.get_child(0) is Fire_Extinguisher:
			holding_extinguisher = true
			if Input.is_action_pressed("use item"):
				using_fire_extinguisher = true
				get_direction().emitting = true
				get_direction().get_child(0).get_child(0).disabled = false
			else:
				using_fire_extinguisher = false
				$Right.emitting = false
				$Left.emitting = false
				$Front.emitting = false
				$Back.emitting = false
				$Right/Area2D/CollisionShape2D.disabled = true
				$Front/Area2D/CollisionShape2D.disabled = true
				$Back/Area2D/CollisionShape2D.disabled = true
				$Left/Area2D/CollisionShape2D.disabled = true
				using_fire_extinguisher = false
		else:
			$Right.emitting = false
			$Left.emitting = false
			$Front.emitting = false
			$Back.emitting = false
			$Right/Area2D/CollisionShape2D.disabled = true
			$Front/Area2D/CollisionShape2D.disabled = true
			$Back/Area2D/CollisionShape2D.disabled = true
			$Left/Area2D/CollisionShape2D.disabled = true
			using_fire_extinguisher = false
			holding_extinguisher = false
	else:
		$Right.emitting = false
		$Left.emitting = false
		$Front.emitting = false
		$Back.emitting = false
		$Right/Area2D/CollisionShape2D.disabled = true
		$Front/Area2D/CollisionShape2D.disabled = true
		$Back/Area2D/CollisionShape2D.disabled = true
		$Left/Area2D/CollisionShape2D.disabled = true
		using_fire_extinguisher = false
		holding_extinguisher = false
	

	update_animation_parameters()
	
	if item_direction.x == 1:
		$Marker2D.position.x = 12
	elif item_direction.x == -1:
		$Marker2D.position.x = -12
	if Input.is_action_just_pressed("debug"):
		var fire_ins = FIRE.instantiate()
		get_tree().root.get_node("Main").add_child(fire_ins)
		fire_ins.global_position = global_position
func get_speed() -> int:
	if Input.is_action_pressed("sprint"):
		return sprint_speed
	return speed
	
func get_acceleration() -> int:
	return 3200
	
func update_animation_parameters():
	
	var direction_ = round(input_vector)
	
	
	if !holding_extinguisher:
		animation_tree.set("parameters/conditions/idle_ex", false)
		animation_tree.set("parameters/conditions/is_moving_ex", false)
		animation_tree.set("parameters/conditions/idle", velocity == Vector2.ZERO)
		animation_tree.set("parameters/conditions/is_moving", velocity != Vector2.ZERO)
	else:
		animation_tree.set("parameters/conditions/idle", false)
		animation_tree.set("parameters/conditions/is_moving", false)
		animation_tree.set("parameters/conditions/is_moving_ex", velocity != Vector2.ZERO)
		animation_tree.set("parameters/conditions/idle_ex", velocity == Vector2.ZERO)
		
	if input_vector:
		item_direction = input_vector
		animation_tree["parameters/Idle/blend_position"] = direction_
		animation_tree["parameters/Walk/blend_position"] = direction_
		animation_tree["parameters/Walk Ex/blend_position"] = direction_
		animation_tree["parameters/Idle Ex/blend_position"] = direction_
	
func get_direction() -> GPUParticles2D:
	
	if item_direction == Vector2(1, 0) or item_direction == Vector2(1, 1) or item_direction == Vector2(1, -1):
		return $Right
		
	elif item_direction == Vector2(-1, 0) or item_direction == Vector2(-1, 1) or item_direction == Vector2(-1, -1):
		return $Left
	elif item_direction == Vector2(0, 1):
		return $Front
	else:
		return $Back
			
