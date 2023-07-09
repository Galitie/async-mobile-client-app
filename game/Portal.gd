@tool
class_name Portal
extends Sprite2D

@export var locked : bool = false:
	set(new_lock_status):
		locked = new_lock_status
		SetLockStatus(locked)
@export var cell_position : Vector2i = Vector2.ZERO:
	set(new_position):
		cell_position = new_position
		SetCellPosition()
@export var trigger_cell : Vector2i
@export var next_map : String
@export var next_map_cell_position : Vector2i
@export var unlocked_sprite_region : Rect2
@export var locked_sprite_region : Rect2

func _ready():
	add_to_group("interactables")
	SetLockStatus(locked)
	set_process(false)
	
func SetCellPosition():
	transform.origin = Vector2(Game.map_cell_size * cell_position.x, Game.map_cell_size * cell_position.y)
	
func SetLockStatus(lock_status):
	if lock_status:
		region_rect = locked_sprite_region
	else:
		region_rect = unlocked_sprite_region

func Use():
	return "portal_entered"
