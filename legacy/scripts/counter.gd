extends CharacterBody2D


var available_spots : Array[Marker2D]
var total_spots: Array[Marker2D]
func _ready() -> void:
	for i in get_children():
		available_spots.append(i)
		total_spots.append(i)
func _physics_process(delta: float) -> void:
	for i in available_spots:
		if i.get_child_count() > 0:
			if i.has_node("Meal"):
				available_spots.erase(i)
	for i in total_spots:
		if !available_spots.has(i) and !i.has_node("Meal"):
			available_spots.append(i)
