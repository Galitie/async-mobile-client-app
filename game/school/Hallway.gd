extends Map

var bgm = load("res://school/backgroundMusic.mp3")

func _ready():
	Game.bgm_player.stream = bgm
	Game.bgm_player.volume_db = -40
	Game.bgm_player.play()
