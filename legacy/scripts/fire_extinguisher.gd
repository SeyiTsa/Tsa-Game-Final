extends Grabbable
class_name Fire_Extinguisher
var is_selected : bool
var cant_be_dropped : bool
@onready var interact_area: Area2D = $"Interact Area"
@export var fire_extinguisher_interaction_array : Array[String] = ["Pick Up", "Put Down"]
var current_choice : bool
func _ready() -> void:
	interact_area.area_entered.connect(on_area_entered)
	interact_area.area_exited.connect(on_area_exited)
	interaction_array.append_array(fire_extinguisher_interaction_array)
	current_interaction = interaction_array[0]
func _physics_process(delta: float) -> void:
	if current_choice and Input.is_action_just_pressed("ui_accept") and on_ground and !InteractionManager.currently_holding_item:
		InteractionManager.currently_holding_item = true
		can_be_selected = false
		on_ground = false
		cant_be_dropped = true
		pick_up()
		if InteractionManager.interaction_list.has(self):
			InteractionManager.interaction_list.erase(self)
	elif !current_choice and Input.is_action_just_pressed("ui_accept") and !on_ground and InteractionManager.interaction_list.size() == 0 and !cant_be_dropped:
		InteractionManager.currently_holding_item = false
		
		can_be_selected = true
		on_ground = true
		put_down()
		if InteractionManager.interaction_list.has(self):
			InteractionManager.interaction_list.erase(self)
		
	if !on_ground:
		$Sprite2D2.hide()
	else:
		$Sprite2D2.show()
	if (is_player_in_area() and can_be_selected and is_selected):
		$Highlight.play("selected")
	else:
		$Highlight.play("RESET")
	if cant_be_dropped:
		await get_tree().process_frame
		cant_be_dropped = false
	if InteractionManager.currently_holding_item:
		can_be_selected = false
	else:
		if on_ground:
			can_be_selected = true
			
	if $"Interact Area".get_overlapping_areas():
		var area = $"Interact Area".get_overlapping_areas()[0]
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
