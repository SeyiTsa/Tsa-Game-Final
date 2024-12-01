extends CanvasLayer

@onready var money_label: Label = $Money/MarginContainer/MoneyLabel
@onready var served_customers_label: Label = $ServedCustomers/MarginContainer/ServedCustomersLabel


const ORDER_NOTE = preload("res://scenes/order_note.tscn")
var note_markers : Array[Marker2D]
var positions : Array = [1, 2, 3, 4]
var used_positions : Array = []
var used_note_markers : Array
var current_orders : Array
var backed_up_orders : Array
var meal_spots : Array
var displaced_meals : Array



func _physics_process(delta: float) -> void:
	money_label.text = str("$ Money : ", Global.money)
	served_customers_label.text = str("Customers Served : ", Global.served_customers, "/", Global.max_customers)
	

func _on_end_day_pressed() -> void:
	get_tree().change_scene_to_packed(preload("res://scenes/day_end_screen.tscn"))
