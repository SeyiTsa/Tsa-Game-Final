extends Camera2D
const LOOK_AHEAD_FACTOR = 0.05
const SHIFT_DURATION = 0.5 
@onready var player: Player = $".."

@onready var prev_cam_pos = get_screen_center_position()

var facing = 0
var center_pos = position
var target_distance = 0
var max_distance = 48
func _process(delta):
	if !player.throwing:
		global_position.y = player.global_position.y - 100
		check_facing()
		prev_cam_pos = get_screen_center_position()
	else:
		var direction = center_pos.direction_to(get_local_mouse_position())
		var target_pos = center_pos + direction * target_distance
		target_pos = target_pos.clamp(center_pos - Vector2(max_distance, max_distance), center_pos + Vector2(max_distance, max_distance))
		position = target_pos 
func check_facing():
	var new_facing = sign(get_screen_center_position().x - prev_cam_pos.x)
	if new_facing != 0 and facing != new_facing:
		facing = new_facing
		var target_offset = get_viewport_rect().size.x * LOOK_AHEAD_FACTOR * facing

		
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position:x", target_offset, SHIFT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		target_distance = center_pos.distance_to(get_local_mouse_position()) / 2
