extends StaticBody2D
class_name OrderMachine

var meals : Array = []

var distance : float:
	set(value):
		distance = value
		OrderManager.order_machines[self] = distance
func _ready() -> void:
	OrderManager.order_machines[self] = distance
func _process(delta: float) -> void:
	if meals and $"Meal Marker".get_child_count() == 0:
		$"Meal Marker".add_child(meals[0])
		meals.remove_at(0)
		
	$Label.text = str(round(distance))
	if Consts.root.current_state == Consts.root.level_states.SERVESTAGE:
		distance = Consts.player.global_position.distance_to(global_position)
func _exit_tree() -> void:
	OrderManager.order_machines.erase(self)
