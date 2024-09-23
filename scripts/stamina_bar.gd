extends TextureProgressBar

@onready var player: CharacterBody2D = $"../../../Player"




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	value = player.stamina
