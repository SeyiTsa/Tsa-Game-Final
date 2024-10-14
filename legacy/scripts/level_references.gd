extends Node

@export var counter : CharacterBody2D
@export var leave_point : Marker2D

@export var day_1_customers : Array[CustomerData]
@export var day_2_customers : Array[CustomerData]
@export var day_3_customers : Array[CustomerData]
@export var day_4_customers : Array[CustomerData]
@export var day_5_customers : Array[CustomerData]
@export var day_6_customers : Array[CustomerData]

@export var time_between_customers : int

var current_customer_array : Array[CustomerData]

var customer_index : int = 0
const CUSTOMER = preload("res://scenes/customer.tscn")
func _ready() -> void:
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
		add_child(customer_ins)
		customer_ins.global_position = leave_point.global_position
		customer_index += 1
		
