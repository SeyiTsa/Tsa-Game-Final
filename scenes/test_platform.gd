extends StaticBody2D

func _ready() -> void:
	$Polygon2D.polygon = $CollisionShape2D.polygon
	$Polygon2D.scale = $CollisionShape2D.scale
	$Polygon2D.position = $CollisionShape2D.position




	
