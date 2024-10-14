extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HBoxContainer/VBoxContainer2/MoneyEarned.text = str("$", Global.money_gained)
	$HBoxContainer/VBoxContainer2/TricksDone.text = str(Global.tricks_done)
	$HBoxContainer/VBoxContainer2/CustomersServed.text = str(Global.served_customers, "/", Global.max_customers)
	$VBoxContainer/MarginContainer/DayNumber.text = str("Day ", Global.current_day, " Completed")





func _on_upgrade_shop_pressed() -> void:
	LevelManager.scene_to_switch_to = "res://scenes/upgrade_shop.tscn"
	get_tree().change_scene_to_packed(preload("res://scenes/load_screen.tscn"))


func _on_next_day_pressed() -> void:
	Global.current_day += 1
	LevelManager.scene_to_switch_to = "res://scenes/level_1.tscn"
	get_tree().change_scene_to_packed(preload("res://scenes/load_screen.tscn"))
	
	


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_packed(preload("res://scenes/main_menu.tscn"))
