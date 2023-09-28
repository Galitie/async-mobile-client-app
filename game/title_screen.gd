extends Control

var transition_finished = false
var title_theme = load("res://title_theme.mp3")
var title_start = load("res://title_start.wav")
var start = false

func _ready():
	Game.bgm_player.stream = title_theme
	Game.bgm_player.play()
	Game.sfx_player.stream = title_start
	Game.sfx_player.finished.connect(_sound_finished)
	UI.transition.get_node("AnimationPlayer").animation_finished.connect(_anim_finished)
	UI.transition.get_node("AnimationPlayer").play("fade_in")
	$Cursor.play()
	
func _anim_finished(anim_name):
	if anim_name == "fade_in":
		transition_finished = true
		
func _sound_finished():
	get_tree().change_scene_to_file("res://main.tscn")

func _process(delta):
	if !start && transition_finished && Input.is_action_just_pressed("interact"):
		UI.transition.get_node("AnimationPlayer").play("fade_out")
		Game.sfx_player.play()
		Game.bgm_player.stop()
		start = true
