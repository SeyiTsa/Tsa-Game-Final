extends AnimatedSprite2D




func set_property(tx_pos, tx_scale, tx = null):
	global_position = tx_pos
	scale = tx_scale
	if tx:
		$Sprite2D.texture = tx
