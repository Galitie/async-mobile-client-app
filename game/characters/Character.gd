class_name Character
extends AnimatedSprite2D

var world

var floating_emoji = preload("res://Emoji.tscn")

var cell_size
var cell_position = Vector2i(0, 0)
var cell_destination = Vector2i.ZERO
var can_move = true
var direction = "south"
var speed = 0.2
var step_index = 0

var follower = null
var character_data

func Init(_world, _character_data):
	world = _world
	character_data = _character_data
	sprite_frames = character_data.sprite_frames
	offset = character_data.sprite_offset
	
	$StepTimer.wait_time = speed / 2.0
	$StepTimer.connect("timeout", _onStep)
	
	cell_size = world.current_map.cell_quadrant_size

func SetCellPosition(cell_pos):
	cell_position = cell_pos
	transform.origin = Vector2(cell_size * cell_position.x, cell_size * cell_position.y)
	
func SetCellDestination(cell_pos, _direction):
	can_move = false
	cell_destination = cell_pos
	var current_frame = frame
	animation = "walk_" + _direction
	frame = current_frame
	direction = _direction
	
	var tile_data = world.current_map.get_cell_tile_data(Game.collision_layer, cell_destination)
	if tile_data:
		cell_destination = Vector2i.ZERO
		can_move = true
		return
		
	for interactable in get_tree().get_nodes_in_group("interactables"):
		if interactable is Portal:
			if cell_destination == interactable.trigger_cell:
				if interactable.locked:
					cell_destination = Vector2i.ZERO
					can_move = true
					return
				else:
					world.emit_signal(interactable.Use(), interactable.next_map, interactable.next_map_cell_position)
		elif interactable is Interactable:
			if !interactable.passable && cell_destination == interactable.cell_position:
				cell_destination = Vector2i.ZERO
				can_move = true
				return
	
	if follower:
		var follower_direction = "south"
		var diff = follower.cell_position - cell_position
		match diff:
			Vector2i(1, 0):
				follower_direction = "west"
			Vector2i(-1, 0):
				follower_direction = "east"
			Vector2i(0, 1):
				follower_direction = "north"
			Vector2i(0, -1):
				follower_direction = "south"
		follower.SetCellDestination(cell_position, follower_direction)
	
	$StepTimer.start()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(cell_size * cell_destination.x, cell_size * cell_destination.y), speed).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(_finishedMoving)

func Update(delta):
	if can_move && Input.is_action_pressed("move_right"):
		SetCellDestination(cell_position + Vector2i(1, 0), "east")
	elif can_move && Input.is_action_pressed("move_left"):
		SetCellDestination(cell_position + Vector2i(-1, 0), "west")
	elif can_move && Input.is_action_pressed("move_up"):
		SetCellDestination(cell_position + Vector2i(0, -1), "north")
	elif can_move && Input.is_action_pressed("move_down"):
		SetCellDestination(cell_position + Vector2i(0, 1), "south")
		
	if Input.is_action_just_pressed("interact"):
		Interact()

func Interact():
	var interact_destination
	match (direction):
		"south":
			interact_destination = cell_position + Vector2i(0, 1)
		"north":
			interact_destination = cell_position + Vector2i(0, -1)
		"east":
			interact_destination = cell_position + Vector2i(1, 0)
		"west":
			interact_destination = cell_position + Vector2i(-1, 0)
	for interactable in get_tree().get_nodes_in_group("interactables"):
		if interactable is Interactable:
			if interactable.cell_position == interact_destination && interactable.Interact():
				if interactable.interact_signal:
					world.current_map.emit_signal(interactable.interact_signal, self, interactable)
				if interactable.messages:
					world.SetMessageQueue(interactable.messages)

func _onStep():
	frame = fmod(frame + 1, 4)
	step_index += 1
	if step_index < 2:
		$StepTimer.start()
	else:
		step_index = 0

func _finishedMoving():
	can_move = true
	cell_position = cell_destination
	
	for interactable in get_tree().get_nodes_in_group("interactables"):
		if interactable is Trigger:
			if cell_destination == interactable.cell_position:
				if interactable.CheckForActivation():
					world.emit_signal("sent_text", {"context": interactable.signal_string})

func Emote(emoji):
	$Emoji.Display(emoji)
