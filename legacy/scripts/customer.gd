extends Interactable
class_name Customer

@onready var interact_area: Area2D = $"Interact Area"
@onready var nav : NavigationAgent2D = $NavigationAgent2D
@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var order_timer: Timer = $"Order Timer"
@export var data : CustomerData
var customer_interactions : Array = ["Follow", "Seat", "Ordering", "Take Order", "Serve", "Eat", "Favor", "Leave"]
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
var is_selected : bool
var current_choice : bool

var patience : float = 100:
	set(value):
		patience = clamp(value, 0, 100)
		
var food_options : Array[String] = ["Burger", "Pizza", "Milk shake", "Taco"]
func _ready() -> void:
	patience_multiplier = data.patience_multplier
	update_animation_parameters(Vector2.ZERO)
	customer = self
	interact_area.area_entered.connect(on_area_entered)
	interact_area.area_exited.connect(on_area_exited)
	interaction_array.append_array(customer_interactions)
	current_interaction = interaction_array[0]
	nav.target_desired_distance = 60
	$ProgressBar.max_value = patience
	
func _physics_process(delta: float) -> void:
	
	

	$ProgressBar.tint_progress = Color.RED.lerp(Color.YELLOW, $ProgressBar.value / $ProgressBar.max_value)
	navigate(delta)
	var dir = to_local(nav.get_next_path_position()).normalized() 
	if should_navigate or is_player_in_area():
		previous_dir = dir
		
	
	if ordering or is_talking or is_sitting or has_order_ready:
		update_animation_parameters(Vector2.ZERO)
	
	$ProgressBar.value = patience
	if InteractionManager.interaction_list.size() > 0:
		if InteractionManager.interaction_list[0] == self:
			current_choice = true
		else:
			current_choice = false
	else:
		current_choice = false
	match current_interaction:
		"Follow":
			if not InteractionManager.current_customer == self:
				patience -= 0.1 * patience_multiplier
			if velocity.x < 0:
				sprite_2d.flip_h = true
			elif velocity.x > 0:
				sprite_2d.flip_h = false
			else:
				if player:
					if player.global_position.x > global_position.x:
						sprite_2d.flip_h = false
					elif player.global_position.x < global_position.x:
						sprite_2d.flip_h = true
						
			if InteractionManager.current_customer:
				can_be_selected = false
			else:
				if !should_navigate:
					can_be_selected = true
				
			if player:
				nav.target_position = player.global_position
		"Seat":
			if not InteractionManager.current_customer == self:
				patience -= 0.1 * patience_multiplier
			if seat:
				if velocity.x < 0:
					sprite_2d.flip_h = true
				elif velocity.x > 0:
					sprite_2d.flip_h = false
				nav.target_position = seat.customer_marker.global_position
		"Take Order":
			if not InteractionManager.current_customer == self:
				patience -= 0.1 * patience_multiplier
		"Serve":
			patience -= 0.1 * patience_multiplier
			if player.holding_meal:
				can_be_selected = true
			else:
				can_be_selected = false
		"Leave":
			if velocity.x < 0:
				sprite_2d.flip_h = true
			elif velocity.x > 0:
				sprite_2d.flip_h = false
	if (is_player_in_area() and can_be_selected and current_choice):
		$Highlight.play("selected")
		
	else:
		$Highlight.play("RESET")
	if InteractionManager.current_customer == self:
		$indicator.show()
	else:
		$indicator.hide()
	if current_choice and Input.is_action_just_pressed("ui_accept"):
		match current_interaction:
			"Follow":
					match InteractionManager.current_customer:
						customer:
							can_be_selected = false
							should_navigate = true
							InteractionManager.customer_currently_following = true
							if InteractionManager.current_customer == self:
								InteractionManager.current_customer = null
							else:
								InteractionManager.current_customer = self
						null:
							can_be_selected = false
							should_navigate = true
							InteractionManager.customer_currently_following = true
							if InteractionManager.current_customer == self:
								InteractionManager.current_customer = null
							else:
								InteractionManager.current_customer = self
			"Take Order":
				if OrderManager.order_list.size() != 4:
					patience += 20
					var food_option = food_options[randi_range(0, food_options.size() - 1)]
					OrderManager.add_order(food_option)
					var index = OrderManager.food_options.find(food_option)
					$"Ordered Food".texture = OrderManager.food_data_options[index].food_liquid
					has_order_ready = false
					$"Order Marker".hide()
					can_be_selected = false
					is_talking = true
					$"Talk Timer".start()
			"Serve":
				if player.holding_meal and InteractionManager.currently_holding_item:
					patience += 20
					can_be_selected = false
					player.marker_2d.get_child(0).reparent(seat.marker_2d)
					seat.marker_2d.get_child(0).can_be_selected = false
					current_interaction = interaction_array[5]
					InteractionManager.currently_holding_item = false
					$"Ordered Food".hide()
					get_tree().create_timer(randf_range(20, 25)).timeout.connect(finished_eating)

				
	elif !current_choice and Input.is_action_just_pressed("ui_accept") and InteractionManager.current_customer == self and !is_player_in_area():
		if InteractionManager.interaction_list.size() == 0:
			match current_interaction:
				"Follow":
					can_be_selected = true
					InteractionManager.current_customer = null
					should_navigate = false
					InteractionManager.customer_currently_following = false

	
	if $"Interact Area".get_overlapping_areas():
		var area = $"Interact Area".get_overlapping_areas()[0]
		if can_be_selected:
			if area.is_in_group("player interact"):
				is_selected = true
				player_in_area = true
				if !InteractionManager.interaction_list.has(self):
					InteractionManager.interaction_list.append(self)
					player = area.get_parent()
		else:
			if area.is_in_group("player interact"):
				player_in_area = true
				is_selected = false
				if InteractionManager.interaction_list.has(self):
					InteractionManager.interaction_list.erase(self)
	else:
		is_selected = false
func navigate(delta):
	if !is_sitting:
		velocity.y += delta * 12500
		move_and_slide()
	else:
		velocity.y = 0
		
	if should_navigate:
		var dir = to_local(nav.get_next_path_position()).normalized()
		update_animation_parameters(dir)
		if !nav.is_navigation_finished():
			velocity.x = dir.x * SPEED
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			match current_interaction:
				"Seat":
					is_sitting = true
					z_index = 0
					if !get_parent() is Chair:
						reparent(seat)
					global_position = seat.customer_marker.global_position
					ordering = true
					if seat.scale.x == -1:
						sprite_2d.flip_h = true
					else:
						sprite_2d.flip_h = false
					current_interaction = interaction_array[2]
					order_timer.start(order_timer.wait_time + randf_range(-3 , 3))
				"Leave":
					queue_free()
			

	else:
		velocity = Vector2.ZERO
		
		if is_player_in_area():
			var dir = to_local(nav.get_next_path_position()).normalized()
			update_animation_parameters(dir)
		else:
			update_animation_parameters(previous_dir)

	
func update_animation_parameters(anim_dir : Vector2):
	var direction = round(anim_dir)
	if !is_sitting and !has_order_ready and !ordering and !is_talking:
		animation_tree.set("parameters/conditions/is_sitting", false)
		animation_tree.set("parameters/conditions/ordering", false)
		animation_tree.set("parameters/conditions/has_order_ready", false)
		animation_tree.set("parameters/conditions/is_talking", false)
		animation_tree.set("parameters/conditions/idle", velocity == Vector2.ZERO)
	else:
		if !has_order_ready and !is_sitting and !is_talking and ordering:
			animation_tree.set("parameters/conditions/ordering", ordering)
			animation_tree.set("parameters/conditions/has_order_ready", false)
			animation_tree.set("parameters/conditions/is_sitting", false)
			animation_tree.set("parameters/conditions/is_talking", false)
		elif !is_sitting and !ordering and !is_talking and has_order_ready:
			animation_tree.set("parameters/conditions/is_sitting", false)
			animation_tree.set("parameters/conditions/ordering", false)
			animation_tree.set("parameters/conditions/is_talking", false)
			animation_tree.set("parameters/conditions/has_order_ready", has_order_ready)
		elif !ordering and !has_order_ready and !is_talking and is_sitting:
			animation_tree.set("parameters/conditions/is_sitting", is_sitting)
			animation_tree.set("parameters/conditions/ordering", false)
			animation_tree.set("parameters/conditions/has_order_ready", false)
			animation_tree.set("parameters/conditions/is_talking", false)
		elif !ordering and !has_order_ready and !is_sitting and is_talking:
			animation_tree.set("parameters/conditions/is_sitting", false)
			animation_tree.set("parameters/conditions/ordering", false)
			animation_tree.set("parameters/conditions/has_order_ready", false)
			animation_tree.set("parameters/conditions/is_talking", is_talking)

		
		animation_tree.set("parameters/conditions/idle", false)
	animation_tree.set("parameters/conditions/is_moving", velocity != Vector2.ZERO)
	animation_tree["parameters/Idle/blend_position"] = direction
	animation_tree["parameters/Walk/blend_position"] = direction
	animation_tree["parameters/Sit/blend_position"] = direction
	animation_tree["parameters/Arm Wave/blend_position"] = direction


	


func _on_order_timer_timeout() -> void:
	ordering = false
	has_order_ready = true
	current_interaction = interaction_array[3]
	$"Order Marker".show()
	can_be_selected = true



func _on_talk_timer_timeout() -> void:

	is_talking = false
	is_sitting = true
	current_interaction = interaction_array[4]
	
func finished_eating():
	seat.marker_2d.get_child(0).queue_free()
	if patience > 0:
		var money = preload("res://scenes/money.tscn")
		var money_ins = money.instantiate()
		seat.marker_2d.add_child(money_ins)
		money_ins.global_position = seat.marker_2d.global_position
		money_ins.get_final_amount(patience)
	current_interaction = customer_interactions[7]
	seat.occupied = false
	seat = null
	is_sitting = false
	is_talking = false
	has_order_ready = false
	ordering = false
	reparent(get_tree().root.get_node("Level1"))
	position.y += 10
	Global.served_customers += 1
	nav.target_position = get_tree().root.get_node("Level1").leave_point.global_position
	should_navigate = true
