extends StaticBody2D
class_name Chair

@onready var marker_2d: Marker2D = $Marker2D_


@onready var customer_marker: Marker2D = $"Customer Marker"
@onready var interactable_component: Interactable = $InteractableComponent


var is_selected : bool

var interactions : Array = ["Seat"]
var occupied : bool




func _physics_process(delta: float) -> void:
	if !InteractionManager.current_customer:
		interactable_component.can_be_selected = false
	else:
		if !occupied:
			interactable_component.can_be_selected = true
			
	if (interactable_component.player_in_area and interactable_component.can_be_selected and interactable_component.selected):
		$Highlight.play("selected")
	else:
		$Highlight.play("RESET")
	if interactable_component.selected and Input.is_action_just_pressed("ui_accept"):
		match interactable_component.current_interaction:
			"Seat":
				if InteractionManager.current_customer and !occupied:
					occupied = true
					InteractionManager.current_customer.interactable_component.switch_interaction.emit()
					InteractionManager.current_customer.seat = self
					InteractionManager.current_customer.table = get_parent()
					InteractionManager.current_customer.nav.target_desired_distance = 52
					InteractionManager.current_customer.should_navigate = true
					InteractionManager.current_customer.patience += 20
					InteractionManager.current_customer = null
					interactable_component.can_be_selected = false
