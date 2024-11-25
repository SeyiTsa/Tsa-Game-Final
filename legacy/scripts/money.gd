extends StaticBody2D


var money : float = 0.0
var is_selected : bool
@onready var interactable_component: Interactable = $InteractableComponent
@export var interactions : Array = ["Pick Up"]

	
func _physics_process(delta: float) -> void:

	if interactable_component.selected and Input.is_action_just_pressed("interact"):
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
