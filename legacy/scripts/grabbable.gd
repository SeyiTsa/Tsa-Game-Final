extends Node2D
class_name Grabbable

var on_ground : bool = true
@export var interactable_component : Interactable

func pick_up():
	
	interactable_component.player.held_items.append(get_parent().data)
	
	if InteractionManager.interaction_list.has(get_parent()):
		InteractionManager.interaction_list.erase(get_parent())
	get_parent().queue_free()
func _physics_process(delta: float) -> void:
	if interactable_component.selected and Input.is_action_just_pressed("interact") and on_ground and interactable_component.can_be_selected:
		if get_parent().on_counter:
			get_parent().reparent(Consts.root)

			get_parent().on_counter = false
		InteractionManager.currently_holding_item = true
		interactable_component.can_be_selected = false
		on_ground = false
		pick_up()

	elif !interactable_component.selected and Input.is_action_just_pressed("interact") and !on_ground and InteractionManager.interaction_list.size() == 0 and get_parent().get_parent().name == "Marker2D":
		interactable_component.can_be_selected = true
		on_ground = true
		put_down()

			
	if !InteractionManager.currently_holding_item:
		if on_ground and get_parent().get_parent().name != "Marker2D_":
			interactable_component.can_be_selected = true
			
	if get_parent().get_parent().name == "Marker2D_" or get_parent().get_parent().name == "Marker2D":
		interactable_component.can_be_selected = false
func put_down():
	Consts.player.held_items.remove_at(0)
	InteractionManager.currently_holding_item = false
	on_ground = true
	get_parent().reparent(Consts.root)
	if InteractionManager.interaction_list.has(get_parent()):
		InteractionManager.interaction_list.erase(get_parent())
		
