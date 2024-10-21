extends Area2D
class_name InteractArea
var player_in_area : bool = false

func _process(delta: float) -> void:
	if get_overlapping_areas() == []:
		player_in_area = false
	else:
		player_in_area = true
