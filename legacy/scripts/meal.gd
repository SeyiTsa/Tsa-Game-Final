extends RigidBody2D
class_name Meal


@export var data : FoodData
@onready var interactable_component: Interactable = $InteractableComponent
@onready var grabbable_component: Grabbable = $GrabbableComponent

@export var interactions : Array = ["Pick Up"]
var on_counter = true


func _ready() -> void:
	$"Plate Glass".texture = data.plate_glass
	$"Food Liquid".texture = data.food_liquid

	
func _physics_process(delta: float) -> void:
	

	if !grabbable_component.on_ground:
		$Sprite2D.hide()
	else:
		$Sprite2D.show()
	if (interactable_component.player_in_area and interactable_component.can_be_selected and interactable_component.selected):
		$Highlight.play("selected")
	else:
		$Highlight.play("RESET")
		

	if get_parent() is Marker2D:
		global_position = get_parent().global_position
		if get_parent().name == "Marker2D_":
			rotation_degrees = 0
	else:
		rotation_degrees = 0

	if get_parent() is Marker2D:
		linear_velocity = Vector2(0, 0)



	if $RayCast2D.is_colliding():
		linear_velocity.y = 0
