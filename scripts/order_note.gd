extends Panel

@export var food_data : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var index = OrderManager.food_options.find(food_data)
	
	var food_texture = OrderManager.food_data_options[index].food_liquid
	$Sprite2D.texture = food_texture
