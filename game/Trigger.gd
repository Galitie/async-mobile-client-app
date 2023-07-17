class_name Trigger
extends Node2D

@export var cell_position : Vector2i
@export var active : bool
@export var oneshot : bool
@export var signal_string : String

func _ready():
	add_to_group("interactables")

func CheckForActivation():
	if active:
		if oneshot:
			active = false
		return true
	return false
