extends CanvasLayer

@onready var money_label: Label = $MarginContainer/MarginContainer/MoneyLabel
const ORDER_NOTE = preload("res://scenes/order_note.tscn")
var note_markers : Array[Marker2D]
var positions : Array = [1, 2, 3, 4]
var used_positions : Array = []
var used_note_markers : Array
var current_orders : Array
var backed_up_orders : Array
func _ready() -> void:
	OrderManager.order_made.connect(meal_made)
	for child in $Control/ColorRect.get_children():
		if child is Marker2D and child.name != "EntranceMarker":
			note_markers.append(child)
func _physics_process(delta: float) -> void:
	if used_positions:
		for note_marker in note_markers:
			if note_marker.get_child_count() > 0:
				var order_note = note_marker.get_child(0)
				var index = note_markers.find(note_marker)
				for position in used_positions:
					if positions[index] > position:
						var position_index = positions.find(position)
						if note_markers[position_index].get_child_count() == 0:
							used_note_markers.erase(note_marker)
							used_positions.erase(position)
							used_positions.append(positions[index])
							used_note_markers.append(note_markers[position_index])
							order_note.reparent(note_markers[position_index])
							var tween = get_tree().create_tween()
							tween.tween_property(order_note, "global_position", note_markers[position_index].global_position, 1).set_trans(Tween.TRANS_SINE)
							
							
	money_label.text = str("$ Money : ", Global.money)
	if backed_up_orders.size() > 0 and used_note_markers.size() < 4:
		for index in note_markers.size():
			if used_note_markers.has(note_markers[index]) == false:
				add_order(backed_up_orders[0].food_data)
				backed_up_orders.remove_at(0)
				break
func _on_end_day_pressed() -> void:
	get_tree().change_scene_to_packed(preload("res://scenes/day_end_screen.tscn"))

func add_order(meal):
	var order_note_ins = ORDER_NOTE.instantiate()
	order_note_ins.food_data = meal
	if used_note_markers.size() < 4:
		
		var tween = get_tree().create_tween()
		
		for index in note_markers.size():
			if used_note_markers.has(note_markers[index]) == false:
				
				note_markers[index].add_child(order_note_ins)
				break
	
		order_note_ins.global_position = $Control/ColorRect/EntranceMarker.global_position
		tween.set_parallel(true)
		tween.tween_property(order_note_ins, "global_position", order_note_ins.get_parent().global_position, 1).set_trans(Tween.TRANS_SINE)
		tween.tween_property(order_note_ins, "rotation_degrees", 0, 1).set_trans(Tween.TRANS_BACK)
		for note in note_markers:
			if !used_note_markers.has(note):
				used_note_markers.append(note)
				var index = note_markers.find(note)
				used_positions.append(positions[index])
				break
		
		await tween.finished
		
	else:
		backed_up_orders.append(order_note_ins)
	
func meal_made():

	var note : Marker2D = used_note_markers[0]
	used_note_markers.remove_at(0)
	
	
	var tween = get_tree().create_tween()

	tween.tween_property(note.get_child(0), "global_position:y", note.position.y - 100, 1).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	

	
	note.get_child(0).queue_free()
