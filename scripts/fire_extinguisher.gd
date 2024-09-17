extends Grabbable
class_name Fire_Extinguisher

var cant_be_dropped : bool
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
		cant_be_dropped = true
		pick_up()
		if InteractionManager.interaction_list.has(self):
			InteractionManager.interaction_list.erase(self)
	elif !is_selected() and Input.is_action_just_pressed("ui_accept") and !on_ground and InteractionManager.interaction_list.size() == 0 and !cant_be_dropped:
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
	if cant_be_dropped:
		await get_tree().process_frame
		cant_be_dropped = false
