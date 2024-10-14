extends Grabbable

@onready var interact_area: Area2D = $"Interact Area"
var money : float = 0.0
var is_selected : bool
var current_choice : bool
func _ready() -> void:
	interact_area.area_entered.connect(on_area_entered)
	interact_area.area_exited.connect(on_area_exited)
	
func _physics_process(delta: float) -> void:

	if current_choice and Input.is_action_just_pressed("ui_accept"):
		Global.money += money
		Global.money_gained += money
		$Label.text = str("+", money)
		$Label.show()
		$Sprite2D.hide()
		var tween = get_tree().create_tween()
		tween.tween_property($Label, "position:y", -30, 0.25).set_ease(Tween.EASE_OUT)
		tween.tween_property($Label, "scale",  Vector2(0, 0), 0.25).set_ease(Tween.EASE_IN)
		tween.tween_property($Label, "modulate", Color(255, 255, 255, 0), 0.25)
		await tween.finished
		queue_free()
	
		
		if InteractionManager.interaction_list.has(self):
			InteractionManager.interaction_list.erase(self)
			
	if is_selected:
		$Highlight.play("selected")
	else:
		$Highlight.play("RESET")
		
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
func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
func get_final_amount(patience_left):
	money += patience_left
	money = money/45
	money = round_to_dec(money, 2)
	if money > 2:
		$Sprite2D.frame = 0
	elif money > 1 and money < 2:
		$Sprite2D.frame = 1
	else:
		$Sprite2D.frame = 2
