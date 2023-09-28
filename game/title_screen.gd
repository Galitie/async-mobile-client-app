extends Control

var transition_finished = false

func _ready():
	UI.transition.get_node("AnimationPlayer").animation_finished.connect(_anim_finished)
	UI.transition.get_node("AnimationPlayer").play("fade_in")
	$Cursor.play()
	
func _anim_finished(anim_name):
	if anim_name == "fade_in":
		transition_finished = true
	elif anim_name == "fade_out":
		get_tree().change_scene_to_file("res://main.tscn")

func _process(delta):
	if transition_finished && Input.is_action_just_pressed("interact"):
		UI.transition.get_node("AnimationPlayer").play("fade_out")
