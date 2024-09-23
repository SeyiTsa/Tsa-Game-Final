extends Control


func toggle():
	visible = !visible
	get_tree().paused = visible

func _on_pause_pressed() -> void:
	toggle()


func _on_unpause_pressed() -> void:
	toggle()


func _on_exit_menu_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://scenes/main_menu.tscn"))


func _on_exit_desktop_pressed() -> void:
	get_tree().quit()
