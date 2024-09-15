extends Node
var notepad : Control
var order_list : Array[String]
func _ready() -> void:
	notepad = get_tree().root.get_node("Main").get_node("CanvasLayer").get_node("Control").get_node("Notepad")
func add_order(order):
	notepad.order_list.append(order)
	order_list.append(order)
	notepad.list_changed()
