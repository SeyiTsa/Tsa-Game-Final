extends Node
var notepad : Control
var order_area : CharacterBody2D
var order_list : Array[String]
var current_batches_in_wait : Array[Array]
var current_batches_being_made : Array[Array]
var wait_timer_started : bool
var backlog : Array = []
var cook_timer_started : bool
const meal = preload("res://scenes/meal.tscn")
var food_data_options : Array[FoodData] = [preload("res://scripts/resources/food data/burger.tres"), preload("res://scripts/resources/food data/taco.tres"),
preload("res://scripts/resources/food data/pizza.tres"), preload("res://scripts/resources/food data/milkshake.tres")]
var food_options : Array[String] = []
signal order_made
func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	for i in food_data_options:
		food_options.append(i.name)
	



func get_references():
	await get_tree().process_frame
	notepad = get_tree().root.get_node("Level1").get_node("UI").get_node("Control").get_node("Notepad")
	order_area = get_tree().root.get_node("Level1").get_node("Order Area")
	

func add_order(order):
	notepad.order_list.append(order)
	order_list.append(order)
	notepad.list_changed()


func new_batch(batch):
	current_batches_in_wait.append(batch)
	notepad.order_list.clear()
	order_list.clear()

		
func _physics_process(delta: float) -> void:
	if !wait_timer_started and current_batches_in_wait.size() > 0:
		wait_timer_started = true
		get_tree().create_timer(randf_range(5, 8), false).timeout.connect(queue_food)

	if !cook_timer_started and current_batches_being_made.size() > 0:
		cook_timer_started = true
		get_tree().create_timer(randf_range(5, 8), false).timeout.connect(make_food)
	if backlog and get_tree().root.get_node("Level1").counter.available_spots:
		for meal in backlog:
			get_tree().root.get_node("Level1").counter.available_spots[0].add_child(meal)
			backlog.erase(meal)
		
func queue_food():
	if order_area and get_tree().paused == false:
		wait_timer_started = false
		for sprite in order_area.sprites:
			await get_tree().process_frame
			if current_batches_in_wait.has(sprite.data) and sprite.visible:
				current_batches_being_made.append(sprite.data)
				current_batches_in_wait.erase(sprite.data)
				order_area.order_queued.emit(sprite)
				break
			elif !sprite.visible:
				continue
	else:
		wait_timer_started = false
		
		
func make_food():
	if get_tree().paused == false:
		var current_meal_set = current_batches_being_made[0]
		for single_meal in current_meal_set:
			if food_options.has(single_meal):
				await get_tree().process_frame
				var index = food_options.find(single_meal)
				var meal_ins = meal.instantiate()
				meal_ins.data = food_data_options[index]
				if get_tree().root.get_node("Level1").counter.available_spots:
					meal_ins.global_position = get_tree().root.get_node("Level1").counter.available_spots[0].global_position
					
					get_tree().root.get_node("Level1").counter.available_spots[0].add_child(meal_ins)
				else:
					
					backlog.append(meal_ins)
		if current_batches_being_made.size() > 0:
			for x in current_meal_set.size():
				order_made.emit()
			current_batches_being_made.remove_at(0)
		cook_timer_started = false 
	else:
		cook_timer_started = false

				

	
	
