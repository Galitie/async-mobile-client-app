extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$Cursor.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file("res://main.tscn")
