extends Camera2D
var input : Vector2
var velocity : Vector2
var SPEED = 7

func get_input():
	input.x = Input.get_action_strength("pan_right") - Input.get_action_strength("pan_left")
	input.y = Input.get_action_strength("pan_down") - Input.get_action_strength("pan_up")
	return input

func _process(delta):

	var playerInput = get_input()
	
	velocity = playerInput * SPEED

	position += velocity
