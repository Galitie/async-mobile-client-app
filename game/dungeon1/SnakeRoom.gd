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

func _ready():
	Game.bgm_player.stream = ambience
	Game.bgm_player.play()
	connect("map_climb_ladder", _climbLadder)
	connect("map_off_ladder", _offLadder)
	connect("map_transition", _transition)
	connect("map_above_ground", _aboveGround)
	timer.connect("timeout", _startSong)
	
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
	transition = true
	
func _aboveGround(packet):
	bathroom.z_index = 0
	bathroom.modulate = Color.WHITE
	transition = false
	above_ground = true
	clear_layer(Game.collision_layer)

func update(delta):
	if !above_ground:
		var host = get_parent().characters[Game.HOST_IP]
		var ladder_progress = host.transform.origin.y / $TopGround.transform.origin.y
		light.energy = lerp(0.4, 1.0, ladder_progress)
		light.color = lerp(light_color, Color.WHITE, ladder_progress)
		light.texture_scale = lerp(1.5, 2.1, ladder_progress)
		light.transform.origin = host.transform.origin
		
		if transition:
			var progress = (host.transform.origin.y - $Transition.transform.origin.y) / ($TopGround.transform.origin.y - $Transition.transform.origin.y)
			print(progress)
			bathroom.modulate = lerp(Color(Color.BLACK, 0), Color.WHITE, progress)
			light.texture_scale = lerp(light.texture_scale, 5.0, progress)
		
		if climbing_ladder && !sfx.playing:
			if host.frame == 1 || host.frame == 3:
				sfx.play()
