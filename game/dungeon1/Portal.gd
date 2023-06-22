class_name Portal
extends Sprite2D

@export var locked : bool
@export var cell_position : Vector2i
@export var trigger_cell : Vector2i
@export var next_map : String
@export var next_map_cell_position : Vector2i
@export var unlocked_sprite_region : Rect2
@export var locked_sprite_region : Rect2

func _ready():
	SetLockStatus(locked)
	var map = get_parent().get_parent()
	transform.origin = Vector2(map.cell_quadrant_size * cell_position.x, map.cell_quadrant_size * cell_position.y)
	set_process(false)
	
func SetLockStatus(lock_status):
	locked = lock_status
	if lock_status:
		region_rect = locked_sprite_region
	else:
		region_rect = unlocked_sprite_region

func Use():
	return "portal_entered"
