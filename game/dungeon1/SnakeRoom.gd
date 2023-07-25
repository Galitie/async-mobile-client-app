extends Map

signal map_climb_ladder
signal map_off_ladder
signal map_transition
signal map_above_ground

@onready var bathroom = $Bathroom
@onready var timer = $SongTimer
@onready var stream_player = $Song
@onready var sfx = $SFX
@onready var light = $PointLight
@onready var light_color = light.color

var climbing_ladder = false
var just_entered = true
var transition = false
var above_ground = false

var ambience = load("res://dungeon1/wind.ogg")

@onready var door_timer = $Bathroom/DoorTimer

func _ready():
	Game.bgm_player.stream = ambience
	Game.bgm_player.play()
	connect("map_climb_ladder", _climbLadder)
	connect("map_off_ladder", _offLadder)
	connect("map_transition", _transition)
	connect("map_above_ground", _aboveGround)
	timer.connect("timeout", _startSong)
	
	door_timer.connect("timeout", _openDoor)
	
func _startSong():
	stream_player.play()
	
func _climbLadder(packet):
	climbing_ladder = true
	if just_entered:	
		just_entered = false
		timer.start()
		
func _offLadder(packet):
	climbing_ladder = false
	
func _transition(packet):
	transition = !transition
	
func _aboveGround(packet):
	set_layer_enabled(0, false)
	set_layer_enabled(1, false)
	set_layer_enabled(2, false)
	bathroom.z_index = 0
	bathroom.modulate = Color.WHITE
	transition = false
	above_ground = true
	clear_layer(Game.collision_layer)
	bathroom.y_sort_enabled = true
	var bathroom_collision = bathroom.get_pattern(Game.collision_layer, bathroom.get_used_cells(Game.collision_layer))
	set_pattern(Game.collision_layer, Vector2i(-3, -224), bathroom_collision)
	
	var host_character = get_parent().characters[Game.HOST_IP]
	var last_frame = host_character.frame
	host_character.frames = host_character.character_data.school_frames
	host_character.offset = host_character.character_data.school_offset
	host_character.frame = last_frame
	
	for character in get_parent().characters:
		get_parent().characters[character].SetCellPosition(host_character.cell_position)
	
	Game.bgm_player.stop()
	get_parent().world_prompt.data["style"] = "cute"
	Game.SendPromptToUsers(get_parent().world_prompt, false)
	door_timer.start()
	
func _openDoor():
	$Bathroom/BathroomDoor.visible = false
	erase_cell(Game.collision_layer, Vector2i(0, -222))

func update(delta):
	if !above_ground:
		var host = get_parent().characters[Game.HOST_IP]
		var ladder_progress = host.transform.origin.y / $TopGround.transform.origin.y
		light.energy = lerp(0.4, 1.0, ladder_progress)
		light.texture_scale = lerp(1.5, 2.1, ladder_progress)
		light.transform.origin = host.transform.origin
		
		if transition:
			var progress = (host.transform.origin.y - $Transition.transform.origin.y) / ($TopGround.transform.origin.y - $Transition.transform.origin.y)
			light.color = lerp(light_color, Color.WHITE, progress)
			bathroom.modulate = lerp(Color(Color.BLACK, 0), Color.WHITE, progress)
			light.texture_scale = lerp(light.texture_scale, 10.0, progress)
		
		if climbing_ladder && !sfx.playing:
			if host.frame == 1 || host.frame == 3:
				sfx.play()
