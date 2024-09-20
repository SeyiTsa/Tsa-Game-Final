extends Node
var notepad : Control
var order_area : CharacterBody2D
var order_list : Array[String]
var current_batches_in_wait : Array[Array]
var current_batches_being_made : Array[Array]
var wait_timer_started : bool
var cook_timer_started : bool

func _ready() -> void:
	notepad = get_tree().root.get_node("Main").get_node("CanvasLayer").get_node("Control").get_node("Notepad")
	order_area = get_tree().root.get_node("Main").get_node("Order Area")
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
		get_tree().create_timer(randf_range(5, 8)).timeout.connect(queue_food)
		
	if !cook_timer_started and current_batches_being_made.size() > 0:
		cook_timer_started = true
		get_tree().create_timer(randf_range(5, 8)).timeout.connect(make_food)
func queue_food():
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
func make_food():
	var current_meal_set = current_batches_being_made[0]
	for meals in current_meal_set:
		print(meals)
	current_batches_being_made.remove_at(0)
	cook_timer_started = false
	
	
