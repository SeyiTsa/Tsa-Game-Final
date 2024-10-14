extends Interactable

class_name Grabbable

var on_ground : bool = true


func pick_up():
	reparent(player.marker_2d)
	global_position = player.marker_2d.global_position
func put_down():
	on_ground = true
	reparent(get_tree().root.get_node("Level1"))
	
