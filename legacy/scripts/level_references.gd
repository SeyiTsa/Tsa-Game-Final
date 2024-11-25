extends Node2D


@export var leave_point : Marker2D

@export var day_1_customers : Array[CustomerData]
@export var day_2_customers : Array[CustomerData]
@export var day_3_customers : Array[CustomerData]
@export var day_4_customers : Array[CustomerData]
@export var day_5_customers : Array[CustomerData]
@export var day_6_customers : Array[CustomerData]

@export var time_between_customers : int

var current_customer_array : Array[CustomerData]
var open_seats : Array
var customer_index : int = 0
const CUSTOMER = preload("res://scenes/customer.tscn")
func _ready() -> void:
	for child in get_children():
		if child.is_in_group("table"):
			for chair in child.get_children():
				if chair is Chair:
					open_seats.append(chair)

	Consts.root = self
	Consts.player = $Player
	
	Global.money_gained = 0.00
	match Global.current_day:
		1:
			current_customer_array = day_1_customers
			Global.max_customers = day_1_customers.size()
			await get_tree().create_timer(time_between_customers, false).timeout
			spawm_customer()
		2:
			current_customer_array = day_2_customers
			Global.max_customers = day_2_customers.size()
			await get_tree().create_timer(time_between_customers, false).timeout
			spawm_customer()
		3:
			current_customer_array = day_3_customers
			Global.max_customers = day_3_customers.size()
			await get_tree().create_timer(time_between_customers, false).timeout
			spawm_customer()
		4:
			current_customer_array = day_4_customers
			Global.max_customers = day_4_customers.size()
			await get_tree().create_timer(time_between_customers, false).timeout
			spawm_customer()
		5:
			current_customer_array = day_5_customers
			Global.max_customers = day_5_customers.size()
			await get_tree().create_timer(time_between_customers, false).timeout
			spawm_customer()
		6:
			current_customer_array = day_6_customers
			Global.max_customers = day_6_customers.size()
			await get_tree().create_timer(time_between_customers, false).timeout
			spawm_customer()
func spawm_customer():
	if current_customer_array.size() > customer_index:
		var customer_ins = CUSTOMER.instantiate()
		customer_ins.data = current_customer_array[customer_index]
		get_tree().create_timer(time_between_customers, false).timeout.connect(spawm_customer)
		var seat_index = randf_range(0, open_seats.size() - 1)
		var seat = open_seats[seat_index]
		add_child(customer_ins)
		customer_ins.global_position = Vector2(seat.global_position.x + seat.scale.x * 300, seat.global_position.y)
		customer_ins.seat = seat
		open_seats.erase(seat)
		customer_index += 1
