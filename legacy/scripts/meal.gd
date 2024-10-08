extends Grabbable
class_name Meal

@onready var interact_area: Area2D = $"RigidBody2D/Interact Area"
@export var data : FoodData
var on_counter = true
var is_selected : bool
var current_choice : bool
func _ready() -> void:
	$"RigidBody2D/Plate Glass".texture = data.plate_glass
	$"RigidBody2D/Food Liquid".texture = data.food_liquid
	interact_area.area_entered.connect(on_area_entered)
	interact_area.area_exited.connect(on_area_exited)
	
func _physics_process(delta: float) -> void:


	if !on_ground:
		$RigidBody2D/Sprite2D.hide()
	else:
		$RigidBody2D/Sprite2D.show()
	if (is_player_in_area() and can_be_selected and is_selected):
		$Highlight.play("selected")
	else:
		$Highlight.play("RESET")
		
	if is_selected and Input.is_action_just_pressed("ui_accept") and on_ground and !InteractionManager.currently_holding_item:
		if on_counter:
			reparent(get_tree().root.get_node("Level1"))

			on_counter = false
		InteractionManager.currently_holding_item = true
		can_be_selected = false
		on_ground = false
		pick_up()
		if InteractionManager.interaction_list.has(self):
			InteractionManager.interaction_list.erase(self)
	elif !is_selected and Input.is_action_just_pressed("ui_accept") and !on_ground and InteractionManager.interaction_list.size() == 0 and get_parent().name == "Marker2D":
		InteractionManager.currently_holding_item = false
		can_be_selected = true
		on_ground = true
		put_down()
		if InteractionManager.interaction_list.has(self):
			InteractionManager.interaction_list.erase(self)
			
	if InteractionManager.currently_holding_item:
		can_be_selected = false
	else:
		if on_ground:
			can_be_selected = true
	if get_parent() is Marker2D:
		$RigidBody2D.global_position = get_parent().global_position
	else:
		rotation_degrees = 0
		$RigidBody2D.rotation_degrees = 0

	if get_parent() is Marker2D:
		$RigidBody2D.linear_velocity = Vector2(0, 0)
	if interact_area.get_overlapping_areas():
		var area = interact_area.get_overlapping_areas()[0]
		if can_be_selected:
			if area.is_in_group("player interact"):
				is_selected = true
				player_in_area = true
				if !InteractionManager.interaction_list.has(self):
					InteractionManager.interaction_list.append(self)
					player = area.get_parent()
		else:
			if area.is_in_group("player interact"):
				player_in_area = true
				is_selected = false
				if InteractionManager.interaction_list.has(self):
					InteractionManager.interaction_list.erase(self)
	else:
		is_selected = false
	if InteractionManager.interaction_list.size() > 0:
		if InteractionManager.interaction_list[0] == self:
			current_choice = true
		else:
			current_choice = false
	else:
		current_choice = false
	if $RayCast2D.is_colliding():
		$RigidBody2D.linear_velocity.y = 0
