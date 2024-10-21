extends StaticBody2D
class_name OrderArea


@onready var interactable_component: Interactable = $InteractableComponent
var interactions : Array = ["Place"]
var current_orders : Array[Array]
var num_of_orders : int

var sprites : Array[Sprite2D]
var visible_sprites : Array[bool]
var is_selected : bool

var used_sprites : Array
signal order_queued(sprite : Sprite2D)

func _ready() -> void:

	for x in get_children():
		if x is Sprite2D:
			sprites.append(x)
			visible_sprites.append(x.visible)
	num_of_orders = sprites.size()
func _physics_process(delta: float) -> void:
	

	if (interactable_component.player_in_area and interactable_component.can_be_selected):
		$Highlight.play("selected")
		
	else:
		$Highlight.play("RESET")
	if OrderManager.order_list.size() > 0 and !num_of_orders > 5:
		interactable_component.can_be_selected = true
	else:
		interactable_component.can_be_selected = false
		
	if Input.is_action_just_pressed("ui_accept") and interactable_component.selected:
		
		current_orders.append(OrderManager.order_list)
		
		for order in current_orders:
			for meal in order:
				$"../UI".add_order(meal)
			break

		show_random_sprite()
		
		
		
		OrderManager.new_batch(OrderManager.order_list.duplicate())
	
	num_of_orders = visible_sprites.count(true)
	


func show_random_sprite():

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
