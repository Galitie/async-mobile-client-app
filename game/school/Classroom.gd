extends Map

signal exit_class

@onready var camera = get_parent().get_node("Camera2D")

var teacher_portrait = load("res://school/portraits/teacher.png")
var tyler_portrait = load("res://school/portraits/teacher.png")

var messages = [
	Message.new("test", "content", "", Message.SignalTiming.NONE, [], null, teacher_portrait),
	Message.new("test", "content2", "exit_class", Message.SignalTiming.DISAPPEAR, ["res://school/Lunchroom.tscn", Vector2i(-1, -27)], tyler_portrait, teacher_portrait)
]

func _ready():
	connect("exit_class", _exit_class)

func init():
	camera.SetTarget(null)
	camera.transform.origin = Vector2(90, 90)
	var world = get_parent()
	world.SetMessageQueue(messages)

func _exit_class(args):
	get_parent().emit_signal("portal_entered", args[0], args[1])

func update(delta):
	pass
