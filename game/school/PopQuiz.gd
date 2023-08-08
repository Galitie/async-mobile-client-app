extends Map

signal exit_class
signal map_intro

@onready var camera = get_parent().get_node("Camera2D")

var teacher_portrait = load("res://school/portraits/teacher.png")
var tyler_portrait = load("res://school/portraits/tyler.png")
var mario_portrait = load("res://school/portraits/mario.png")
var kermit_portrait = load("res://school/portraits/kermit.png")
var snake_portrait = load("res://school/portraits/snake.png")
var shadow_portrait = load("res://school/portraits/shadow.png")
var shrek_portrait = load("res://school/portraits/shrek.png")

var pre_quiz_messages = [
	Message.new("test", "Now that you all have eaten, it's time for a pop quiz!", "", Message.SignalTiming.NONE, [], null, teacher_portrait),
	Message.new("test", "SHIT!", "", Message.SignalTiming.NONE, [], tyler_portrait, teacher_portrait)
]

var question_prompt1 = Game.Prompt.new("What is Tyler's SSN?", "map_intro", "countdown", 60.0, false, {"big": "ああ、大好きだよ
the Government"})

func _ready():
	connect("exit_class", _exit_class)
	Game.SendPromptToUsers(Game.wait_prompt, false)

func init():
	camera.SetTarget(null)
	camera.transform.origin = Vector2(90, 90)
	var world = get_parent()
	world.SetMessageQueue(pre_quiz_messages)

func _exit_class(args):
	get_parent().emit_signal("portal_entered", args[0], args[1])

func update(delta):
	pass
