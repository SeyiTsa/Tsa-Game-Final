extends Interactable
class_name OrderArea


@onready var interact_area: Area2D = $"Interact Area"
var current_orders : Array[Array]
var num_of_orders : int
@onready var _1: Sprite2D = $"1"
@onready var _2: Sprite2D = $"2"
@onready var _3: Sprite2D = $"3"
@onready var _4: Sprite2D = $"4"
@onready var _5: Sprite2D = $"5"
var sprites : Array[Sprite2D]
var visible_sprites : Array[bool]
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
	

	if (is_player_in_area() and can_be_selected and is_selected()):
		$Highlight.play("selected")
		
	else:
		$Highlight.play("RESET")
	if OrderManager.order_list.size() > 0 and !num_of_orders > 5:
		can_be_selected = true
	else:
		can_be_selected = false
		
	if Input.is_action_just_pressed("ui_accept") and is_selected():
		current_orders.append(OrderManager.order_list)
		show_random_sprite()
		
		
		
		OrderManager.new_batch(OrderManager.order_list.duplicate())
	
	num_of_orders = visible_sprites.count(true)
func show_random_sprite():
	var random_sprite = sprites[randi_range(0, sprites.size() - 1)]
	if !random_sprite.visible:
		random_sprite.show()
		visible_sprites.clear()
		for x in get_children():
			if x is Sprite2D:
				sprites.append(x)
				visible_sprites.append(x.visible)
		random_sprite.data = current_orders[current_orders.size() - 1].duplicate()
	else:
		show_random_sprite()


func _on_order_queued(sprite: Sprite2D) -> void:
	current_orders.erase(sprite.data)
	sprite.hide()
	visible_sprites.clear()
	for x in get_children():
		if x is Sprite2D:
			sprites.append(x)
			visible_sprites.append(x.visible)
