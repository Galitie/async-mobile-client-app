extends TileMap

signal pushCrate

const COLLISION_LAYER = 3

func _ready():
	connect("pushCrate", _pushCrate)
	set_process(false)

func _pushCrate(character, object):
	var direction = Vector2i(0, 0)
	match character.direction:
		"north":
			direction = Vector2i(0, -1)
		"south":
			direction = Vector2i(0, 1)
		"east":
			direction = Vector2i(1, 0)
		"west":
			direction = Vector2i(-1, 0)
	var destination = object.cell_position + direction
	var tile_data = get_cell_tile_data(COLLISION_LAYER, destination)
	if tile_data:
		return
	for obj in $Objects.get_children():
		if obj.cell_position == destination:
			return
	object.SetCellPosition(destination, false)
