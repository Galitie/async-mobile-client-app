extends Map

signal map_climb_ladder
signal map_off_ladder

@onready var timer = $SongTimer
@onready var stream_player = $Song
@onready var sfx = $SFX
@onready var light = $PointLight
@onready var light_color = light.color
var climbing_ladder = false
var just_entered = true

func _ready():
	connect("map_climb_ladder", _climbLadder)
	connect("map_off_ladder", _offLadder)
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

func update(delta):
	var host = get_parent().characters[Game.HOST_IP]
	var ladder_progress = host.transform.origin.y / $TopGround.transform.origin.y
	light.energy = lerp(0.4, 1.0, ladder_progress)
	light.color = lerp(light_color, Color.WHITE, ladder_progress)
	light.texture_scale = lerp(1.5, 3.0, ladder_progress)
	light.transform.origin = host.transform.origin
	if climbing_ladder && !sfx.playing:
		if get_parent().characters[Game.HOST_IP].frame == 1 || get_parent().characters[Game.HOST_IP].frame == 3:
			sfx.play()
