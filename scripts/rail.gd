extends StaticBody2D


@export var rotated : bool

func _ready() -> void:
	$Polygon2D.polygon = $CollisionShape2D.polygon
	$Polygon2D.scale = $CollisionShape2D.scale
	$Polygon2D.global_position = $CollisionShape2D.global_position
