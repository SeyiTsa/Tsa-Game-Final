extends PanelContainer

var state : String
@onready var anim: AnimationPlayer = $AnimationPlayer
var already_up : bool = false
var order_list : Array[String]
var override : bool = false


@onready var timer: Timer = $Timer

func _ready() -> void:
	anim.play("RESET")
func _physics_process(delta: float) -> void:
	for index in order_list.size():
		if !(order_list.size() > (get_child_count() - 1)):
			get_child(index).get_child(0).text = order_list[index]
func _on_mouse_entered() -> void:
	if state != "Up":
		already_up = true
		anim.play("pop up")
		state = "Up"
 


func _on_mouse_exited() -> void:
	if state != "Down" and !override:
		anim.play("down")
		state = "Down"
		already_up = false

func _on_timer_timeout() -> void:
	if state != "Down":
		anim.play("down")
		state = "Down"
		already_up = false
		override = false
		
func list_changed():
	if !already_up:
		anim.play("pop up")
		state = "Up"
		timer.start()
		already_up = true
	else:
		timer.start()
