extends Sprite2D

@export var one_shot : bool
@export var cell_position : Vector2i
@export var interact_sprite : Rect2
@export var interact_signal : String
@export var messages : Array

var map
var interacted_with = false

func _ready():
	map = get_parent().get_parent()
	SetCellPosition(cell_position)
	set_process(false)

func SetCellPosition(cell_pos):
	transform.origin = Vector2(map.cell_quadrant_size * cell_pos.x, map.cell_quadrant_size * cell_pos.y)
