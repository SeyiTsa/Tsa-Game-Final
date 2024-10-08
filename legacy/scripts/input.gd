extends Control


@onready var input_button = preload("res://scenes/input_button.tscn")
@onready var action_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList

var is_remapping : bool = false
var action_to_remap = null
var remapping_button = null
var input_actions : Dictionary = {"right" : "Right", "left" : "Left", "up" : "Up","grind" : "Grind", "push_off" :"Push Off", "use item" : "Use Item"}
func _ready() -> void:
	create_action_list()
	
func create_action_list():
	InputMap.load_from_project_settings()
	for item in action_list.get_children():
		item.queue_free()
		
	for action in input_actions:
		var button = input_button.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")
		action_label.text = input_actions[action]
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
		action_list.add_child(button)
		button.pressed.connect(on_input_button_pressed.bind(button, action))
		
func on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press Key to Bind..."
func _input(event: InputEvent) -> void:
	if is_remapping:
		if (event is InputEventKey or (event is InputEventMouseButton and event.pressed)):
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			update_action_list(remapping_button, event)
			if event is InputEventMouseButton and event.double_click:
				event.double_click = false
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			accept_event()
func update_action_list(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")


func _on_reset_button_pressed() -> void:
	create_action_list()
