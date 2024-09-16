extends Grabbable
class_name Fire_Extinguisher

@onready var interact_area: Area2D = $"Interact Area"
@export var fire_extinguisher_interaction_array : Array[String] = ["Pick Up", "Put Down"]
func _ready() -> void:
	interact_area.area_entered.connect(on_area_entered)
	interact_area.area_exited.connect(on_area_exited)
	interaction_array.append_array(fire_extinguisher_interaction_array)
	current_interaction = interaction_array[0]
func _physics_process(delta: float) -> void:
	if is_selected() and Input.is_action_just_pressed("ui_accept") and on_ground:
		can_be_selected = false
		on_ground = false
		pick_up()
		if InteractionManager.interaction_list.has(self):
			InteractionManager.interaction_list.erase(self)
	elif !is_selected() and Input.is_action_just_pressed("ui_accept") and !on_ground and InteractionManager.interaction_list.size() == 0:
		can_be_selected = true
		on_ground = true
		put_down()
		if InteractionManager.interaction_list.has(self):
			InteractionManager.interaction_list.erase(self)
		
	if !on_ground:
		$Sprite2D2.hide()
	else:
		$Sprite2D2.show()
	if (is_player_in_area() and can_be_selected):
		$Highlight.play("selected")
	else:
		$Highlight.play("RESET")
