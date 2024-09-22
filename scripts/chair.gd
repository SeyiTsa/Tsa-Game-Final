extends Interactable
class_name Chair

@onready var marker_2d: Marker2D = $Marker2D_

@onready var interact_area: Area2D = $"Interact Area"
@onready var customer_marker: Marker2D = $"Customer Marker"


var table_interactions : Array = ["Seat"]
var occupied : bool


func _ready() -> void:
	
	interact_area.area_entered.connect(on_area_entered)
	interact_area.area_exited.connect(on_area_exited)
	interaction_array.append_array(table_interactions)
	current_interaction = interaction_array[0]


func _physics_process(delta: float) -> void:
	if !InteractionManager.current_customer:
		can_be_selected = false
	else:
		if !occupied:
			can_be_selected = true
	if (is_player_in_area() and can_be_selected and is_selected()):
		$Highlight.play("selected")
	else:
		$Highlight.play("RESET")
	if is_selected() and Input.is_action_just_pressed("ui_accept"):
		match current_interaction:
			"Seat":
				if InteractionManager.current_customer and !occupied:
					occupied = true
					InteractionManager.current_customer.current_interaction = InteractionManager.current_customer.interaction_array[1]
					InteractionManager.current_customer.seat = self
					InteractionManager.current_customer.table = get_parent()
					InteractionManager.current_customer.nav.target_desired_distance = 52
					InteractionManager.current_customer.should_navigate = true
					InteractionManager.current_customer.patience += 20
					InteractionManager.current_customer = null
					can_be_selected = false
	
	if $"Interact Area".get_overlapping_areas() != []:
		on_area_entered($"Interact Area".get_overlapping_areas()[0])
