extends Interactable
class_name Grabbable

var on_ground : bool = true


func pick_up():
	reparent(player.marker_2d)
	global_position = player.marker_2d.global_position
func put_down():
	reparent(get_tree().root.get_node("Main"))
	global_position.y += 13.5
