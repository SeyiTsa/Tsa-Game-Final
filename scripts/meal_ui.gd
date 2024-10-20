extends Sprite2D

var data : FoodData
var meal : Meal
func _physics_process(delta: float) -> void:
	if data and !$Plate.texture:
		$Plate.texture = data.big_plate_glass
		$Food.texture = data.big_food_liquid
	elif !data:
		$Plate.texture = null
		$Food.texture = null
	if meal:
		if meal.on_counter == false:
			data = null
			meal = null
