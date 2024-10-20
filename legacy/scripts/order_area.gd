extends Interactable
class_name OrderArea


@onready var interact_area: Area2D = $"Interact Area"
var current_orders : Array[Array]
var num_of_orders : int

var sprites : Array[Sprite2D]
var visible_sprites : Array[bool]
var is_selected : bool
var current_choice : bool
var used_sprites : Array
signal order_queued(sprite : Sprite2D)

func _ready() -> void:
	interact_area.area_entered.connect(on_area_entered)
	interact_area.area_exited.connect(on_area_exited)
	for x in get_children():
		if x is Sprite2D:
			sprites.append(x)
			visible_sprites.append(x.visible)
	num_of_orders = sprites.size()
func _physics_process(delta: float) -> void:
	

	if (is_player_in_area() and can_be_selected and current_choice):
		$Highlight.play("selected")
		
	else:
		$Highlight.play("RESET")
	if OrderManager.order_list.size() > 0 and !num_of_orders > 5:
		can_be_selected = true
	else:
		can_be_selected = false
		
	if Input.is_action_just_pressed("ui_accept") and current_choice:
		
		current_orders.append(OrderManager.order_list)
		
		for order in current_orders:
			for meal in order:
				$"../UI".add_order(meal)
			break

		show_random_sprite()
		
		
		
		OrderManager.new_batch(OrderManager.order_list.duplicate())
	
	num_of_orders = visible_sprites.count(true)
	
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
	if InteractionManager.interaction_list.size() > 0:
		if InteractionManager.interaction_list[0] == self:
			current_choice = true
		else:
			current_choice = false
	else:
		current_choice = false
func show_random_sprite():
	#var random_sprite = sprites[randi_range(0, sprites.size() - 1)]
	#if !random_sprite.visible:
		#random_sprite.show()
		#visible_sprites.clear()
		#for x in get_children():
			#if x is Sprite2D:
				#sprites.append(x)
				#visible_sprites.append(x.visible)
		#random_sprite.data = current_orders[current_orders.size() - 1].duplicate()
	#else:
		#show_random_sprite()
	for sprite in sprites:
		if !used_sprites.has(sprite):
			used_sprites.append(sprite)
			sprite.show()
			sprite.data = current_orders[current_orders.size() - 1].duplicate()
			break

func _on_order_queued(sprite: Sprite2D) -> void:
	current_orders.erase(sprite.data)
	sprite.hide()
	used_sprites.erase(sprite)
	visible_sprites.clear()
	for x in get_children():
		if x is Sprite2D:
			sprites.append(x)
			visible_sprites.append(x.visible)
