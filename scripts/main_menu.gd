extends Control

@onready var menu: VBoxContainer = $Menu
@onready var settings: Control = $Settings
@onready var video: Control = $Video
@onready var audio: Control = $Audio
@onready var input: Control = $Input
@onready var saves: Control = $Saves

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle()

func toggle():
	visible = !visible
	get_tree().paused = visible


func _on_start_pressed() -> void:
	show_and_hide(saves, menu)


func _on_settings_pressed() -> void:
	show_and_hide(settings, menu)
	
func show_and_hide(first, second):
	first.show()
	second.hide()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_audio_pressed() -> void:
	show_and_hide(audio, settings)


func _on_back_from_settings_pressed() -> void:
	show_and_hide(menu, settings)


func _on_fullscreen_toggled(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_borderless_toggled(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_v_sync_toggled(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _on_back_from_video_pressed() -> void:
	show_and_hide(settings, video)


func _on_video_pressed() -> void:
	show_and_hide(video, settings)



func _on_master_value_changed(value: float) -> void:
	volume(0, value)

func volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, value)

func _on_music_value_changed(value: float) -> void:
	volume(1, value)


func _on_sound_fx_value_changed(value: float) -> void:
	volume(2, value)


func _on_back_from_audio_pressed() -> void:
	show_and_hide(settings, audio)


func _on_controls_pressed() -> void:
	show_and_hide(input, settings)


func _on_back_from_input_pressed() -> void:
	show_and_hide(settings, input)


func _on_back_from_saves_pressed() -> void:
	show_and_hide(menu, saves)


func _on_save_1_pressed() -> void:
	toggle()
	get_tree().change_scene_to_packed(preload("res://scenes/load_screen.tscn"))


func _on_save_2_pressed() -> void:
	toggle()
	get_tree().change_scene_to_packed(preload("res://scenes/load_screen.tscn"))


func _on_save_3_pressed() -> void:
	toggle()
	get_tree().change_scene_to_packed(preload("res://scenes/load_screen.tscn"))
