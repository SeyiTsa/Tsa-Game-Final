extends CharacterBody2D
class_name Customer

var on_counter : bool
@onready var nav : NavigationAgent2D = $NavigationAgent2D


@onready var order_timer: Timer = $"Order Timer"
@export var data : CustomerData
@onready var interactable_component: Interactable = $InteractableComponent



var interactions : Array = ["Follow", "Seat", "Ordering", "Take Order", "Serve", "Eat", "Favor", "Leave"]
var SPEED : int = 50
var should_navigate : bool = false
var seat : Chair
var table
var customer : Customer
var ordering : bool
var patience_multiplier : float
var is_sitting : bool
var has_order_ready : bool = false
var previous_dir : Vector2
var is_talking : bool



var patience : float = 100:
	set(value):
		patience = clamp(value, 0, 100)
		
var food_options : Array[String] = ["Burger", "Pizza", "Milk shake", "Taco"]
func _ready() -> void:
	patience_multiplier = data.patience_multplier

	customer = self

	

	
	nav.target_desired_distance = 60
	$ProgressBar.max_value = patience
	
func _physics_process(delta: float) -> void:
	if interactable_component.current_interaction == "Serve":
		$InteractAreaComponent.set_collision_mask_value(4, true)
	else:
		$InteractAreaComponent.set_collision_mask_value(4, false)
	for area in $InteractAreaComponent.get_overlapping_areas():
		if area.is_in_group("meal") and interactable_component.current_interaction == "Serve":
			if area.get_parent().being_thrown:
				area.get_parent().interactable_component.can_be_selected = false
				
				area.get_parent().reparent(seat.marker_2d)
				patience += 20
				interactable_component.can_be_selected = false
				
				for x in 2:
					interactable_component.switch_interaction.emit()
				$"Ordered Food".hide()
				get_tree().create_timer(randf_range(20, 25)).timeout.connect(finished_eating)
				area.get_parent().interactable_component.can_be_selected = false
			
	$Label.text = str(interactable_component.player_in_area)
	

	$ProgressBar.tint_progress = Color.RED.lerp(Color.YELLOW, $ProgressBar.value / $ProgressBar.max_value)
	navigate(delta)
	var dir = to_local(nav.get_next_path_position()).normalized() 
	if should_navigate or interactable_component.player_in_area:
		previous_dir = dir

	$ProgressBar.value = patience

	match interactable_component.current_interaction:
		"Follow":
			if not InteractionManager.current_customer == self:
				patience -= 0.1 * patience_multiplier
				
			if InteractionManager.current_customer:
				interactable_component.can_be_selected = false
			else:
				if !should_navigate:
					interactable_component.can_be_selected = true
				
			if interactable_component.player:
				nav.target_position = interactable_component.player.global_position
		"Seat":
			if not InteractionManager.current_customer == self:
				patience -= 0.1 * patience_multiplier
			if seat:
				nav.target_position = seat.customer_marker.global_position
		"Take Order":
			if not InteractionManager.current_customer == self:
				patience -= 0.1 * patience_multiplier
		"Serve":
			patience -= 0.1 * patience_multiplier
			if interactable_component.player.holding_meal:
				interactable_component.can_be_selected = true
			else:
				interactable_component.can_be_selected = false
				
	if (interactable_component.player_in_area and interactable_component.selected):
		$Highlight.play("selected")
		
	else:
		$Highlight.play("RESET")
	if InteractionManager.current_customer == self:
		$indicator.show()
	else:
		$indicator.hide()
	if interactable_component.selected and Input.is_action_just_pressed("ui_accept"):
		match interactable_component.current_interaction:
			"Follow":
					match InteractionManager.current_customer:
						customer:
							interactable_component.can_be_selected = false
							should_navigate = true
							InteractionManager.customer_currently_following = true
							if InteractionManager.current_customer == self:
								InteractionManager.current_customer = null
							else:
								InteractionManager.current_customer = self
						null:
							interactable_component.can_be_selected = false
							should_navigate = true
							InteractionManager.customer_currently_following = true
							if InteractionManager.current_customer == self:
								InteractionManager.current_customer = null
							else:
								InteractionManager.current_customer = self
			"Take Order":
				patience += 20
				var food_option = food_options[randi_range(0, food_options.size() - 1)]
				OrderManager.add_order(food_option)
				var index = OrderManager.food_options.find(food_option)
				$"Ordered Food".texture = OrderManager.food_data_options[index].food_liquid
				has_order_ready = false
				$"Order Marker".hide()
				interactable_component.can_be_selected = false
				is_talking = true
				$"Talk Timer".start()
			"Serve":
				if (interactable_component.player.holding_meal and InteractionManager.currently_holding_item):
					patience += 20
					interactable_component.can_be_selected = false
					interactable_component.player.marker_2d.get_child(0).reparent(seat.marker_2d)
					seat.marker_2d.get_child(0).interactable_component.can_be_selected = false
					for x in 2:
						interactable_component.switch_interaction.emit()
					InteractionManager.currently_holding_item = false
					$"Ordered Food".hide()
					get_tree().create_timer(randf_range(20, 25)).timeout.connect(finished_eating)

				
	elif !interactable_component.selected and Input.is_action_just_pressed("ui_accept") and InteractionManager.current_customer == self and !interactable_component.player_in_area:
		if InteractionManager.interaction_list.size() == 0:
			match interactable_component.current_interaction:
				"Follow":
					interactable_component.can_be_selected = true
					InteractionManager.current_customer = null
					should_navigate = false
					InteractionManager.customer_currently_following = false

	

func navigate(delta):
	if !is_sitting:
		velocity.y += delta * 12500
		move_and_slide()
	else:
		velocity.y = 0
		
	if should_navigate:
		var dir = to_local(nav.get_next_path_position()).normalized()
		if !nav.is_navigation_finished():
			velocity.x = dir.x * SPEED
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			match interactable_component.current_interaction:
				"Seat":
					is_sitting = true
					z_index = 0
					if !get_parent() is Chair:
						reparent(seat)
					global_position = seat.customer_marker.global_position
					ordering = true
					interactable_component.switch_interaction.emit()
					order_timer.start(order_timer.wait_time + randf_range(-3 , 3))
				"Leave":
					queue_free()
			

	else:
		velocity = Vector2.ZERO
		
		if interactable_component.player_in_area:
			var dir = to_local(nav.get_next_path_position()).normalized()


	

	


func _on_order_timer_timeout() -> void:
	ordering = false
	has_order_ready = true
	interactable_component.switch_interaction.emit()
	$"Order Marker".show()
	interactable_component.can_be_selected = true



func _on_talk_timer_timeout() -> void:

	is_talking = false
	is_sitting = true
	interactable_component.switch_interaction.emit()
	
func finished_eating():
	seat.marker_2d.get_child(0).queue_free()
	if patience > 0:
		var money = preload("res://scenes/money.tscn")
		var money_ins = money.instantiate()
		seat.marker_2d.add_child(money_ins)
		money_ins.global_position = seat.marker_2d.global_position
		money_ins.get_final_amount(patience)
	interactable_component.switch_interaction.emit()
	seat.occupied = false
	seat = null
	is_sitting = false
	is_talking = false
	has_order_ready = false
	ordering = false
	reparent(Consts.root)
	position.y += 10
	Global.served_customers += 1
	nav.target_position = Consts.root.leave_point.global_position
	should_navigate = true
