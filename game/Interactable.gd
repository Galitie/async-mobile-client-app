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
	add_to_group("interactables")
	SetCellPosition(cell_position)
	set_process(false)
	
func SetCellPosition(cell_pos, instant = true):
	if instant:
		transform.origin = Vector2(Game.map_cell_size * cell_position.x, Game.map_cell_size * cell_position.y)
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", Vector2(Game.map_cell_size * cell_pos.x, Game.map_cell_size * cell_pos.y), speed).set_trans(Tween.TRANS_LINEAR)
		var callable = Callable(self, "finishedMoving")
		tween.tween_callback(callable.bind(cell_pos))

func Interact():
	if !one_shot || (one_shot && !interacted_with):
		region_rect = interact_sprite
		interacted_with = true
		return true
	return false
	
func finishedMoving(cell_pos):
	cell_position = cell_pos
