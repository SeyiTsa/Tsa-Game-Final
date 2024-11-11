extends Node

var money : float = 0.00
var money_gained : float = 0.00
var tricks_done : int = 0
var max_customers : int
var served_customers : int
var current_day : int = 1



var mins_til_update = 10
var player

var hour = 12
var minute = 0
var time = str(hour,":", 0, minute)
func _ready():
	
	get_tree().create_timer(0.6).timeout.connect(on_minute_timeout)
	

	

func on_minute_timeout():
	mins_til_update -= 1

		
	minute += 1

	if minute == 60:
		minute = 0
		hour += 1
	if hour == 13:
		hour = 1

	get_tree().create_timer(0.6).timeout.connect(on_minute_timeout)




	if mins_til_update == 0:
		if minute < 10:
			time = str(hour,":", 0, minute)
		else:
			time = str(hour,":", minute)
		mins_til_update = 10
