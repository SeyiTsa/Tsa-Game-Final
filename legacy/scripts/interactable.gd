extends Node2D
class_name Interactable

@export var interaction_array : Array = []
@export var interact_area : InteractArea

signal switch_interaction()
var player_in_area : bool = false
var selected : bool
var current_interaction : String
var player : CharacterBody2D
var can_be_selected : bool = true

func _ready() -> void:
	interaction_array.append_array(get_parent().interactions)
	interact_area.area_entered.connect(on_area_entered)
	interact_area.area_exited.connect(on_area_exited)

	
	current_interaction = interaction_array[0]
	
func on_area_entered(area: Area2D):
	if can_be_selected:
		if area.is_in_group("player interact"):
			player_in_area = true
			if !InteractionManager.interaction_list.has(get_parent()):
				InteractionManager.interaction_list.append(get_parent())
				player = area.get_parent()
	else:
		if area.is_in_group("player interact"):
			player_in_area = true
			if InteractionManager.interaction_list.has(get_parent()):
				InteractionManager.interaction_list.erase(get_parent())
				
func _physics_process(delta: float) -> void:
	player_in_area = interact_area.player_in_area
	if InteractionManager.interaction_list.size() > 0:
		if InteractionManager.interaction_list[0] == get_parent():
			selected = true
		else:
			selected = false
	else:
		selected = false
	
	if interact_area.get_overlapping_areas():
		var area = interact_area.get_overlapping_areas()[0]
		if can_be_selected:
			if area.is_in_group("player interact"):
				selected = true
				player_in_area = true
				if !InteractionManager.interaction_list.has(get_parent()):
					InteractionManager.interaction_list.append(get_parent())
					player = area.get_parent()
		else:
			if area.is_in_group("player interact"):
				player_in_area = true
				selected = false
				if InteractionManager.interaction_list.has(get_parent()):
					InteractionManager.interaction_list.erase(get_parent())
	else:
		selected = false
func on_area_exited(area: Area2D):
	if area.is_in_group("player interact"):
		player_in_area = false
		if InteractionManager.interaction_list.has(get_parent()):
			InteractionManager.interaction_list.erase(get_parent())
	




func _on_switch_interaction() -> void:
	var index = interaction_array.find(current_interaction) + 1
	if index < (interaction_array.size() - 1):
		current_interaction = interaction_array[index]
