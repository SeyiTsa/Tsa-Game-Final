extends Node2D
class_name Grabbable

var on_ground : bool = true
@export var interactable_component : Interactable

func pick_up():
	get_parent().reparent(interactable_component.player.marker_2d)
	global_position = interactable_component.player.marker_2d.global_position
	if InteractionManager.interaction_list.has(get_parent()):
		InteractionManager.interaction_list.erase(get_parent())
func _physics_process(delta: float) -> void:
	if interactable_component.selected and Input.is_action_just_pressed("ui_accept") and on_ground and !InteractionManager.currently_holding_item:
		if get_parent().on_counter:
			get_parent().reparent(get_tree().root.get_node("Level1"))

			get_parent().on_counter = false
		InteractionManager.currently_holding_item = true
		interactable_component.can_be_selected = false
		on_ground = false
		pick_up()

	elif !interactable_component.selected and Input.is_action_just_pressed("ui_accept") and !on_ground and InteractionManager.interaction_list.size() == 0 and get_parent().get_parent().name == "Marker2D":
		InteractionManager.currently_holding_item = false
		interactable_component.can_be_selected = true
		on_ground = true
		put_down()

			
	if InteractionManager.currently_holding_item:
		interactable_component.can_be_selected = false
	else:
		if on_ground:
			interactable_component.can_be_selected = true
			
func put_down():
	on_ground = true
	get_parent().reparent(get_tree().root.get_node("Level1"))
	if InteractionManager.interaction_list.has(get_parent()):
		InteractionManager.interaction_list.erase(get_parent())
		
