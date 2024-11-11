extends Node
#var notepad : Control
#var order_area : StaticBody2D
#var order_list : Array[String]
#var current_batches_in_wait : Array[Array]
#var current_batches_being_made : Array[Array]
#var wait_timer_started : bool
#var backlog : Array = []
#var cook_timer_started : bool
const MEAL = preload("res://scenes/meal.tscn")
var order_machines : Dictionary = {}
var closest_order_machine : OrderMachine

var food_data_options : Array = [preload("res://scripts/resources/fooddata/burger.tres"), preload("res://scripts/resources/fooddata/milkshake.tres"),
preload("res://scripts/resources/fooddata/taco.tres"), preload("res://scripts/resources/fooddata/pizza.tres")]
var food_options : Array[String] = []

#signal order_made(meal, counter_spot, total_counter_spots)
func _ready() -> void:

	process_mode = PROCESS_MODE_ALWAYS
	for i in food_data_options:
		food_options.append(i.name)
	




func add_order(order):
	#
	#notepad.order_list.append(order)
	#order_list.append(order)
	#notepad.list_changed()
	if food_options.has(order):
		var index = food_options.find(order)
		var meal_ins = MEAL.instantiate()
		meal_ins.data = food_data_options[index]
		closest_order_machine.meals.append(meal_ins)
#
#func new_batch(batch):
	#current_batches_in_wait.append(batch)
	#notepad.order_list.clear()
	#order_list.clear()

		
func _physics_process(delta: float) -> void:
	var closest_order_machine_distance = INF
	
	for item in order_machines:
		var machine = order_machines[item]
		if machine < closest_order_machine_distance:
			closest_order_machine_distance = machine
			closest_order_machine = item
	
	#if !wait_timer_started and current_batches_in_wait.size() > 0:
		#wait_timer_started = true
		#get_tree().create_timer(randf_range(5, 8), false).timeout.connect(queue_food)
#
	#if !cook_timer_started and current_batches_being_made.size() > 0:
		#cook_timer_started = true
		#get_tree().create_timer(randf_range(5, 8), false).timeout.connect(make_food)
	#if backlog and get_tree().root.get_node("Level1").counter.available_spots:
		#for meal in backlog:
			#order_made.emit(null, get_tree().root.get_node("Level1").counter.available_spots[0], get_tree().root.get_node("Level1").counter.total_spots)
			#get_tree().root.get_node("Level1").counter.available_spots[0].add_child(meal)
			#backlog.erase(meal)
		#
#func queue_food():
	#if order_area and get_tree().paused == false:
		#wait_timer_started = false
		#for sprite in order_area.sprites:
			#await get_tree().process_frame
			#if current_batches_in_wait.has(sprite.data) and sprite.visible:
				#current_batches_being_made.append(sprite.data)
				#current_batches_in_wait.erase(sprite.data)
				#order_area.order_queued.emit(sprite)
				#break
			#elif !sprite.visible:
				#continue
	#else:
		#wait_timer_started = false
		#
		#
#func make_food():
	#if get_tree().paused == false:
		#var current_meal_set = current_batches_being_made[0]
		#for single_meal in current_meal_set:
			#if food_options.has(single_meal):
				#await get_tree().process_frame
				#var index = food_options.find(single_meal)
				#var meal_ins = MEAL.instantiate()
				#meal_ins.data = food_data_options[index]
				#if get_tree().root.get_node("Level1").counter.available_spots:
					#meal_ins.global_position = get_tree().root.get_node("Level1").counter.available_spots[0].global_position
					#order_made.emit(meal_ins, get_tree().root.get_node("Level1").counter.available_spots[0], get_tree().root.get_node("Level1").counter.total_spots)
					#get_tree().root.get_node("Level1").counter.available_spots[0].add_child(meal_ins)
					#
				#else:
					#order_made.emit(meal_ins, null, get_tree().root.get_node("Level1").counter.total_spots)
					#backlog.append(meal_ins)
		#if current_batches_being_made.size() > 0:
			#current_batches_being_made.remove_at(0)
			#
		#cook_timer_started = false 
	#else:
		#cook_timer_started = false
#
				#

	
	
