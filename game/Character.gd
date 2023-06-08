class_name Character
extends AnimatedSprite2D

var world
var cell_size
var cell_position = Vector2(0, 0)
var cell_destination = Vector2i.ZERO
var can_move = true
var direction = "south"
var speed = 0.2
var step_index = 0

@export var is_player : bool
@export_node_path("Character") var follower

func _ready():
	# TTS voices need to be installed from either the Windows speech package downloader in settings or from the
	# runtime here: https://www.microsoft.com/en-us/download/details.aspx?id=27224
	# Then the registry key for each voice needs to be exported, and their paths changed from OneSpeech to
	# Speech to be recognized by Godot
	# Snake is MSTTS_V110_jaJP_IchiroM
	# Shrek is MSTTS_V110_enIE_SeanM 
	# Mario is MSTTS_V110_itIT_CosimoM
	var voices = DisplayServer.tts_get_voices()
	var voice_id = voices[1]["id"]
	for voice in voices:
		pass
	#DisplayServer.tts_speak("Mamma mia Tyler! This is a no good!", voice_id, 80, 2.0, 1.0, 0)
	
	$StepTimer.wait_time = speed / 2.0
	$StepTimer.connect("timeout", _onStep)
	
	world = get_parent().get_parent()
	cell_size = world.get_node("TileMap").cell_quadrant_size
	SetCellPosition(Vector2i(-1, 0))

func SetCellPosition(cell_pos):
	cell_position = cell_pos
	transform.origin = Vector2(cell_size * cell_position.x, cell_size * cell_position.y)
	
func SetCellDestination(cell_pos, _direction):
	can_move = false
	cell_destination = cell_pos
	var current_frame = frame
	animation = "walk_" + _direction
	frame = current_frame
	
	var tile_data = world.get_node("TileMap").get_cell_tile_data(3, cell_destination)
	if tile_data:
		cell_destination = Vector2i.ZERO
		can_move = true
		return
	
	if follower:
		get_node(follower).SetCellDestination(cell_position, direction)
	direction = _direction
	
	$StepTimer.start()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(cell_size * cell_destination.x, cell_size * cell_destination.y), speed).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(_finishedMoving)

func _process(delta):
	if is_player:
		if can_move && Input.is_action_pressed("ui_right"):
			SetCellDestination(cell_position + Vector2i(1, 0), "east")
		elif can_move && Input.is_action_pressed("ui_left"):
			SetCellDestination(cell_position + Vector2i(-1, 0), "west")
		elif can_move && Input.is_action_pressed("ui_up"):
			SetCellDestination(cell_position + Vector2i(0, -1), "north")
		elif can_move && Input.is_action_pressed("ui_down"):
			SetCellDestination(cell_position + Vector2i(0, 1), "south")

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
