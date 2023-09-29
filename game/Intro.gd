extends Control

var skip = false

func _ready():
	UI.money.visible = false
	$VideoStreamPlayer.finished.connect(_finished)
	UI.transition.get_node("AnimationPlayer").animation_finished.connect(_anim_finished)
	
func _finished():
	UI.transition.get_node("AnimationPlayer").play("fade_out")
	
func _anim_finished(anim_name):
	get_tree().change_scene_to_file("res://title_screen.tscn")

func _process(delta):
	if Input.is_action_just_pressed("interact") && !skip:
		UI.transition.get_node("AnimationPlayer").play("fade_out")
		skip = true
