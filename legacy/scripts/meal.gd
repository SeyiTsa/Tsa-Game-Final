extends RigidBody2D
class_name Meal


@export var data : FoodData
@onready var interactable_component: Interactable = $InteractableComponent
@onready var grabbable_component: Grabbable = $GrabbableComponent
@export var arc_height_factor: float = 0.5
@export var interactions : Array = ["Pick Up"]
var on_counter = true
var being_thrown : bool
var ghost_timer_started : bool = false
const GHOST_SPRITE = preload("res://scenes/ghost_sprite.tscn")
func _ready() -> void:
	$"Plate Glass".texture = data.plate_glass
	$"Food Liquid".texture = data.food_liquid

	
func _physics_process(delta: float) -> void:
	$Label.text = str(interactable_component.can_be_selected, interactable_component.selected)


	if (interactable_component.player_in_area and interactable_component.can_be_selected and interactable_component.selected):
		$Highlight.play("selected")
	else:
		$Highlight.play("RESET")
		

	if get_parent() is Marker2D:
		global_position = get_parent().global_position
		if get_parent().name == "Marker2D_":
			interactable_component.can_be_selected = false
			rotation_degrees = 0
	else:
		rotation_degrees = 0




	if get_parent() is Marker2D:
		linear_velocity = Vector2.ZERO
		being_thrown = false
	if $RayCast2D.is_colliding() and being_thrown:
		linear_velocity.y = 0
		await get_tree().create_timer(0.2).timeout
		being_thrown = false
		
	var collision = move_and_collide(linear_velocity * delta)
	if not collision:
		linear_velocity = linear_velocity.move_toward(Vector2.ZERO, delta * 500)
	else:
		linear_velocity = linear_velocity.bounce(collision.get_normal()) * 0.6
		
	if Engine.time_scale != 1 and !ghost_timer_started and being_thrown:
		ghost_timer_started = true
		var ghost_ins = GHOST_SPRITE.instantiate()
		ghost_ins.set_property(global_position, $"Plate Glass".scale, $"Food Liquid".texture)
		Consts.root.get_node("Overlay").add_child(ghost_ins)
		ghost_ins.position.y -= 7
		await get_tree().create_timer(0.015).timeout
		ghost_timer_started = false
	
func throw(start_position: Vector2, target_position: Vector2, throw_type):
	being_thrown = true
	if throw_type == "Arc":
		var speed_multiplier = 1.2
		var distance = start_position.distance_to(target_position)

			# Midpoint for the arc, adjusting height based on arc height factor
		var mid_point = (start_position + target_position) / 2
		mid_point.y -= distance * arc_height_factor  # Adjust arc height

			# Estimate the time to reach the target based on distance and gravity
		var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
		var time = sqrt(2 * distance / gravity)  # Adjust with speed multiplier

			# Calculate the initial velocity components
		var velocity_x = (target_position.x - start_position.x) / time
		var velocity_y = ((target_position.y - start_position.y) + (2 * mid_point.y - start_position.y - target_position.y)) / (2 * time)

			# Apply the calculated velocity to the RigidBody2D
		linear_velocity = Vector2(velocity_x, velocity_y)  * speed_multiplier
	else:
		var direction = (target_position - start_position)
		gravity_scale = 0.5
		direction = direction * 2
		linear_velocity = direction
		await get_tree().create_timer(0.5).timeout 
		gravity_scale = 1.5
