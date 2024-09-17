extends StaticBody2D


var health = 100

func _physics_process(delta: float) -> void:
	for area in $Area2D.get_overlapping_areas():
		if area.is_in_group("ex"):
			health -= 0.4
			if health <= 0:
				queue_free()
				print("e")
	if $Area2D.get_overlapping_areas() == []:
		if health < 100:
			health += 0.2
	$AnimatedSprite2D.self_modulate = Color(1, 1, 1, health/100)
	$ProgressBar.self_modulate = Color(1, 1, 1, health/50)
	if health >= 100:
		$ProgressBar.hide()
	else:
		$ProgressBar.show()
	$ProgressBar.value = health
