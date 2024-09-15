extends CharacterBody2D

var direction : Vector2
var speed : int = 200
var sprint_speed : int = 300
var input_vector : Vector2

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_tree: AnimationTree = $AnimationTree

func _process(delta: float) -> void:
	
	direction = Input.get_vector("left","right","up","down").normalized()
	
	if direction:
		velocity = velocity.move_toward(direction * get_speed(), delta * get_acceleration())
	else:
		velocity = velocity.move_toward(Vector2.ZERO, delta * get_acceleration())
	move_and_slide()
	
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	if velocity.x < 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = false
		
	update_animation_parameters()
func get_speed() -> int:
	if Input.is_action_pressed("sprint"):
		return sprint_speed
	return speed
	
func get_acceleration() -> int:
	return 3200
	
func update_animation_parameters():
	
	var direction = round(input_vector)
	
	animation_tree.set("parameters/conditions/idle", velocity == Vector2.ZERO)
	animation_tree.set("parameters/conditions/is_moving", velocity != Vector2.ZERO)
	if input_vector:
		animation_tree["parameters/Idle/blend_position"] = direction
		animation_tree["parameters/Walk/blend_position"] = direction
