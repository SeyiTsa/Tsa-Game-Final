extends Interactable
class_name Customer

@onready var interact_area: Area2D = $"Interact Area"
@onready var nav : NavigationAgent2D = $NavigationAgent2D
@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var order_timer: Timer = $"Order Timer"

var customer_interactions : Array = ["Follow", "Seat", "Ordering", "Take Order", "Serve"]
var SPEED : int = 150
var should_navigate : bool = false
var seat : Chair
var customer : Customer
var ordering : bool

var is_sitting : bool
var has_order_ready : bool = false
var previous_dir : Vector2
var is_talking : bool

var food_options : Array[String] = ["Burger", "Pizza", "Milk Shake", "Taco"]
func _ready() -> void:
	update_animation_parameters(Vector2.ZERO)
	customer = self
	interact_area.area_entered.connect(on_area_entered)
	interact_area.area_exited.connect(on_area_exited)
	interaction_array.append_array(customer_interactions)
	current_interaction = interaction_array[0]
	nav.target_desired_distance = 60


func _physics_process(delta: float) -> void:
	navigate()
	var dir = to_local(nav.get_next_path_position()).normalized() 
	if should_navigate:
		previous_dir = dir
	$Label.text = str(is_selected())
	if ordering or is_talking or is_sitting or has_order_ready:
		update_animation_parameters(Vector2.ZERO)
		
	match current_interaction:
		"Follow":
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
			if seat:
				if velocity.x < 0:
					sprite_2d.flip_h = true
				elif velocity.x > 0:
					sprite_2d.flip_h = false
				nav.target_position = seat.customer_marker.global_position
	
	
	if is_selected() and Input.is_action_just_pressed("ui_accept"):
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
					var food_option = food_options[randi_range(0, food_options.size() - 1)]
					OrderManager.add_order(food_option)
					has_order_ready = false
					$"Order Marker".hide()
					can_be_selected = false
					is_talking = true
					$"Talk Timer".start()
				
	elif !is_selected() and Input.is_action_just_pressed("ui_accept") and InteractionManager.current_customer == self and !is_player_in_area():
		if InteractionManager.interaction_list.size() == 0:
			match current_interaction:
				"Follow":
					can_be_selected = true
					InteractionManager.current_customer = null
					should_navigate = false
					InteractionManager.customer_currently_following = false
func navigate():
	if should_navigate:
		var dir = to_local(nav.get_next_path_position()).normalized()
		update_animation_parameters(dir)
		if !nav.is_navigation_finished():
			velocity = dir * SPEED
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			match current_interaction:
				"Seat":
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

	
