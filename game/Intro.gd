extends Control

func _ready():
	UI.money.visible = false
	$VideoStreamPlayer.finished.connect(_finished)
	
func _finished():
	get_tree().change_scene_to_file("res://title_screen.tscn")

func _process(delta):
	if Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file("res://title_screen.tscn")
