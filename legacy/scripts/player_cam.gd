extends Camera2D
const LOOK_AHEAD_FACTOR = 0.05
const SHIFT_DURATION = 0.5 

@onready var prev_cam_pos = get_screen_center_position()

var facing = 0


func _process(delta):
	global_position.y = $"..".global_position.y - 100
	check_facing()
	prev_cam_pos = get_screen_center_position()

func check_facing():
	var new_facing = sign(get_screen_center_position().x - prev_cam_pos.x)
	if new_facing != 0 and facing != new_facing:
		facing = new_facing
		var target_offset = get_viewport_rect().size.x * LOOK_AHEAD_FACTOR * facing

		
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position:x", target_offset, SHIFT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
