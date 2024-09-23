extends Control

var progress = []
var sceneName
var scene_load_status
@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	sceneName = "res://scenes/main.tscn"
	ResourceLoader.load_threaded_request(sceneName)
	
func _process(delta: float) -> void:
	scene_load_status = ResourceLoader.load_threaded_get_status(sceneName, progress)
	progress_bar.value = floor(progress[0] * 100)
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var new_scene = ResourceLoader.load_threaded_get(sceneName)
		get_tree().change_scene_to_packed(new_scene)
		OrderManager.get_references()
