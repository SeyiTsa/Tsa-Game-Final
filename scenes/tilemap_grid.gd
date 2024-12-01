extends Node2D
class_name WorldMapGrid

@export var tile_map: TileMapLayer


@export var grid_color: Color


var vertical_points: PackedVector2Array
var horizontal_points: PackedVector2Array

func _ready() -> void:

	var tilemap_rect := tile_map.get_used_rect()
	var tilemap_cell_size := tile_map.tile_set.tile_size

	for y in tilemap_rect.size.y:
		horizontal_points.append(Vector2(0, y * tilemap_cell_size.y))
		horizontal_points.append(Vector2(tilemap_rect.size.x * tilemap_cell_size.x, y * tilemap_cell_size.y))
	
	for x in tilemap_rect.size.x:
		vertical_points.append(Vector2(x * tilemap_cell_size.x, 0))
		vertical_points.append(Vector2(x * tilemap_cell_size.x, tilemap_rect.size.y * tilemap_cell_size.y))

func _draw() -> void:
	draw_multiline(horizontal_points, grid_color)
	draw_multiline(vertical_points, grid_color)
