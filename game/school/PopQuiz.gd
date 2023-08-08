extends Map

signal exit_class
signal map_intro
signal show_notes

@onready var camera = get_parent().get_node("Camera2D")

var teacher_portrait = load("res://school/portraits/teacher.png")
var tyler_portrait = load("res://school/portraits/tyler.png")
var mario_portrait = load("res://school/portraits/mario.png")
var kermit_portrait = load("res://school/portraits/kermit.png")
var snake_portrait = load("res://school/portraits/snake.png")
var shadow_portrait = load("res://school/portraits/shadow.png")
var shrek_portrait = load("res://school/portraits/shrek.png")

var pre_note_messages = [
	Message.new("test", "Oh wow a love note on my desk haha", "show_notes", Message.SignalTiming.DISAPPEAR, [], tyler_portrait, null)
]

var note_reactions = [
	[
		Message.new("test", "Woah there's another one?!", "show_notes", Message.SignalTiming.DISAPPEAR, [], tyler_portrait, null)
	],
	[
		Message.new("test", "There's more...", "show_notes", Message.SignalTiming.DISAPPEAR, [], tyler_portrait, null)
	],
	[
		Message.new("test", "Uh...", "show_notes", Message.SignalTiming.DISAPPEAR, [], tyler_portrait, null)
	],
	[
		Message.new("test", "...", "show_notes", Message.SignalTiming.DISAPPEAR, [], tyler_portrait, null)
	],
	[
		Message.new("test", ".............", "show_notes", Message.SignalTiming.DISAPPEAR, [], tyler_portrait, null)
	]
]
var reaction_index = 0

var pre_quiz_messages = [
	Message.new("test", "Ok class, time for a pop quiz!", "", Message.SignalTiming.NONE, [], null, teacher_portrait),
	Message.new("test", "Huh??", "", Message.SignalTiming.NONE, [], tyler_portrait, teacher_portrait)
]

var question_prompt1 = Game.Prompt.new("What is Tyler's SSN?", "map_intro", "countdown", 60.0, false, {"big": "ああ、大好きだよ
the Government"})

func _ready():
	connect("exit_class", _exit_class)
	connect("show_notes", _show_notes)
	Game.SendPromptToUsers(Game.wait_prompt, false)

func init():
	camera.SetTarget(null)
	camera.transform.origin = Vector2(90, 90)
	var world = get_parent()
	world.SetMessageQueue(pre_note_messages)

func _show_notes(args):
	UI.love_note.get_node("Text").text = get_parent().love_notes[reaction_index]
	UI.love_note.visible = true
	reaction_index += 1

func _exit_class(args):
	get_parent().emit_signal("portal_entered", args[0], args[1])

func update(delta):
	if UI.love_note.visible && Input.is_action_just_pressed("interact"):
		UI.love_note.visible = false
		if reaction_index >= get_parent().love_notes.size():
			get_parent().SetMessageQueue(pre_quiz_messages)
		else:
			get_parent().SetMessageQueue(note_reactions[reaction_index])
		
