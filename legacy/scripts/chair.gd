extends Interactable
class_name Chair

@onready var marker_2d: Marker2D = $Marker2D_

@onready var interact_area: Area2D = $"Interact Area"
@onready var customer_marker: Marker2D = $"Customer Marker"

var is_selected : bool

var table_interactions : Array = ["Seat"]
var occupied : bool
var current_choice : bool

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
	if (is_player_in_area() and can_be_selected and current_choice):
		$Highlight.play("selected")
	else:
		$Highlight.play("RESET")
	if current_choice and Input.is_action_just_pressed("ui_accept"):
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
	if InteractionManager.interaction_list.size() > 0:
		if InteractionManager.interaction_list[0] == self:
			current_choice = true
		else:
			current_choice = false
	else:
		current_choice = false
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
