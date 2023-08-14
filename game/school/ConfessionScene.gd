extends Node2D

@onready var confessionMusic = $confessionMusic
@onready var sakuraPetals = $SakuraPetals

# Called when the node enters the scene tree for the first time.
func _ready():
	confessionMusic.play()
	sakuraPetals.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
