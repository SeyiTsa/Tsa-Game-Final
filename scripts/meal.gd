extends Grabbable
class_name Meal

@onready var interact_area: Area2D = $"Interact Area"
@export var data : FoodData
var on_counter = true
func _ready() -> void:
	$"Plate Glass".texture = data.plate_glass
	$"Food Liquid".texture = data.food_liquid
	interact_area.area_entered.connect(on_area_entered)
	interact_area.area_exited.connect(on_area_exited)
	
func _physics_process(delta: float) -> void:
	if !on_ground:
		$Sprite2D.hide()
	else:
		$Sprite2D.show()
	if (is_player_in_area() and can_be_selected and is_selected()):
		$Highlight.play("selected")
	else:
		$Highlight.play("RESET")
		
	if is_selected() and Input.is_action_just_pressed("ui_accept") and on_ground and !InteractionManager.currently_holding_item:
		if on_counter:
			reparent(get_tree().root.get_node("Main"))

			on_counter = false
		InteractionManager.currently_holding_item = true
		can_be_selected = false
		on_ground = false
		pick_up()
		if InteractionManager.interaction_list.has(self):
			InteractionManager.interaction_list.erase(self)
	elif !is_selected() and Input.is_action_just_pressed("ui_accept") and !on_ground and InteractionManager.interaction_list.size() == 0 and get_parent().name == "Marker2D":
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
		global_position = get_parent().global_position
	$Label.text = str(z_index)
