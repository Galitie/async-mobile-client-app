extends Control

func _ready():
	UI.money.visible = false
	$VideoStreamPlayer.finished.connect(_finished)
	
func _finished():
	get_tree().change_scene_to_file("res://main.tscn")
