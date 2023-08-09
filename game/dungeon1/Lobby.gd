extends Map

signal all_players_joined
var music = load("res://dungeon1/dungeon.mp3")

func _ready():
	$OutsideDoor.SetLockStatus(false)
	connect("all_players_joined", _allPlayersJoined)
	set_process(false)
	Game.bgm_player.stream = music
	Game.bgm_player.play()

func _allPlayersJoined():
	$OutsideDoor.SetLockStatus(false)
	$PointLight2D.energy *= 1.5
