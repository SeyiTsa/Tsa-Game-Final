extends TileMapLayer

var able_to_place : bool 
@onready var floor: TileMapLayer = $"../Floor"
@onready var placeable_floor: TileMapLayer = $"../Placeable Floor"
@export var max_order_machines : int
var placed_tiles : Array = []
var current_tile


func _process(delta: float) -> void:

	current_tile = local_to_map(get_local_mouse_position())
	if placed_tiles.size() < max_order_machines and Consts.root.current_state == Consts.root.level_states.BUILDSTAGE:
		place_tile()
	else:
		for tile in get_used_cells():
			if get_cell_source_id(tile) != 1:
				erase_cell(tile)
	if placed_tiles.has(current_tile) and Input.is_action_just_pressed("throw") and get_used_cells().has(current_tile) and Consts.root.current_state == Consts.root.level_states.BUILDSTAGE:
		placed_tiles.erase(current_tile)
		erase_cell(current_tile)
	
func place_tile():


	if able_to_place:
		if not placed_tiles.has(current_tile):
			set_cell(current_tile, 0, Vector2i(6, 0), 0)
	else:
		if not placed_tiles.has(current_tile):
			set_cell(current_tile, 0, Vector2i(3, 0), 0)
	
	if able_to_place and Input.is_action_just_pressed("interact"):
		if able_to_place and !placed_tiles.has(current_tile):
			placed_tiles.append(current_tile)
			set_cell(current_tile, 1, Vector2i(0, 0), 1)


	for tile in placed_tiles:
		for floor_tile in floor.get_used_cells():
			if tile == floor_tile:
				placed_tiles.erase(tile)
				erase_cell(tile)
		

		
	for cell in get_used_cells():
		if cell != current_tile and not placed_tiles.has(cell): 
			erase_cell(cell)
			

	if placeable_floor.get_used_cells().has(Vector2i(current_tile.x, current_tile.y + 2)) and not floor.get_used_cells().has(current_tile) and not floor.get_used_cells().has(Vector2i(current_tile.x, current_tile.y + 1)):
		able_to_place = true
	else:
		able_to_place = false
