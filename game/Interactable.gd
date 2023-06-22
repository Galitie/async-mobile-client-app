class_name Interactable
extends Sprite2D

@export var one_shot : bool
@export var cell_position : Vector2i
@export var interact_sprite : Rect2
@export var interact_signal : String
@export var messages : Array

var interacted_with = false

func _ready():
	var map = get_parent().get_parent()
	transform.origin = Vector2(map.cell_quadrant_size * cell_position.x, map.cell_quadrant_size * cell_position.y)
	set_process(false)

func Interact():
	if !one_shot || (one_shot && !interacted_with):
		region_rect = interact_sprite
		interacted_with = true
		return true
	return false
