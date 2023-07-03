@tool
class_name Interactable
extends Sprite2D

@export var passable : bool
@export var one_shot : bool
@export var cell_position : Vector2i = Vector2.ZERO:
	set(new_position):
		cell_position = new_position
		SetCellPosition(cell_position)
@export var interact_sprite : Rect2
@export var interact_signal : String
@export var messages : Array[Resource]

const speed = 0.2
var interacted_with = false

func _ready():
	SetCellPosition(cell_position)
	set_process(false)
	
func SetCellPosition(cell_pos, instant = true):
	var map = get_parent().get_parent()
	if instant:
		transform.origin = Vector2(map.cell_quadrant_size * cell_position.x, map.cell_quadrant_size * cell_position.y)
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", Vector2(map.cell_quadrant_size * cell_pos.x, map.cell_quadrant_size * cell_pos.y), speed).set_trans(Tween.TRANS_LINEAR)

func Interact():
	if !one_shot || (one_shot && !interacted_with):
		region_rect = interact_sprite
		interacted_with = true
		return true
	return false
