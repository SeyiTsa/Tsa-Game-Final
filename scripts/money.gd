extends Grabbable

@onready var interact_area: Area2D = $"Interact Area"
var money : float = 0.0

func _ready() -> void:
	interact_area.area_entered.connect(on_area_entered)
	interact_area.area_exited.connect(on_area_exited)
	
func _physics_process(delta: float) -> void:

	if is_selected() and Input.is_action_just_pressed("ui_accept"):
		queue_free()
	
		Global.money += money
		if InteractionManager.interaction_list.has(self):
			InteractionManager.interaction_list.erase(self)
			
	if is_selected():
		$Highlight.play("selected")
	else:
		$Highlight.play("RESET")
		
func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
func get_final_amount(patience_left):
	money += patience_left
	money = money/45
	money = round_to_dec(money, 2)
	print(money)
	if money > 2:
		$Sprite2D.frame = 0
	elif money > 1 and money < 2:
		$Sprite2D.frame = 1
	else:
		$Sprite2D.frame = 2
