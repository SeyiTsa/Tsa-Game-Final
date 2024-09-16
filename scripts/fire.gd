extends StaticBody2D




func _on_area_2d_area_entered(area: Area2D) -> void:
	print("e")
	if area.is_in_group("ex"):
		queue_free()
