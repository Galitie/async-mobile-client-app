extends Map

signal exit_class
signal intros_submitted
signal intro_finished
signal wait_for_intro
signal map_intro

@onready var camera = get_parent().get_node("Camera2D")

var teacher_portrait = load("res://school/portraits/teacher.png")
var tyler_portrait = load("res://school/portraits/tyler.png")
var mario_portrait = load("res://school/portraits/mario.png")
var kermit_portrait = load("res://school/portraits/kermit.png")
var snake_portrait = load("res://school/portraits/snake.png")
var shadow_portrait = load("res://school/portraits/shadow.png")
var shrek_portrait = load("res://school/portraits/shrek.png")

var pre_intro_messages = [
	Message.new("test", "Welcome class~!", "", Message.SignalTiming.NONE, [], null, teacher_portrait),
	Message.new("test", "Tsch, I just made it!", "", Message.SignalTiming.NONE, [], tyler_portrait, teacher_portrait),
	Message.new("test", "Looks like we have some new students!", "", Message.SignalTiming.NONE, [], tyler_portrait, teacher_portrait),
	Message.new("test", "Please introduce yourself!", "wait_for_intro", Message.SignalTiming.DISAPPEAR, [], tyler_portrait, teacher_portrait)
]

var intro_messages = {
	"Mario" : [
		Message.new("Mario", "Itsame ", "", Message.SignalTiming.NONE, [], null , mario_portrait),
		Message.new("Mario", "INTRO", "", Message.SignalTiming.NONE, [], null, mario_portrait),
		Message.new("Mario", "yahoo!", "intro_finished", Message.SignalTiming.DISAPPEAR, [], null, mario_portrait),
	],
	"Snake" : [
		Message.new("Snake", "Metal...gear...", "", Message.SignalTiming.NONE, [], null, snake_portrait),
		Message.new("Snake", "INTRO", "", Message.SignalTiming.NONE, [], null, snake_portrait),
		Message.new("Snake", "Kept you waiting, huh?", "intro_finished", Message.SignalTiming.DISAPPEAR, [], null, snake_portrait),
	],
	"Shrek" : [
		Message.new("Shrek", "*farts*", "", Message.SignalTiming.NONE, [], null, shrek_portrait),
		Message.new("Shrek", "INTRO", "", Message.SignalTiming.NONE, [], null, shrek_portrait),
		Message.new("Shrek", "*farts again*", "intro_finished", Message.SignalTiming.DISAPPEAR, [], null, shrek_portrait),
	],
	"Kermit" : [
		Message.new("Kermit", "Hi ho!", "", Message.SignalTiming.NONE, [], null, kermit_portrait),
		Message.new("Kermit", "INTRO", "", Message.SignalTiming.NONE, [], null, kermit_portrait),
		Message.new("Kermit", "Yaaaaaaaaaaay!", "intro_finished", Message.SignalTiming.DISAPPEAR, [], null, kermit_portrait),
	],	
	"Shadow" : [
		Message.new("Shadow", "I am the ultimate life form!", "", Message.SignalTiming.NONE, [], null, shadow_portrait),
		Message.new("Shadow", "INTRO", "", Message.SignalTiming.NONE, [], null, shadow_portrait),
		Message.new("Shadow", "Chaos...emerald...", "intro_finished", Message.SignalTiming.DISAPPEAR, [], null, shadow_portrait),
	],
}

var post_intro_messages = [
	Message.new("test", "Oh! Was that the bell? See you after lunch!", "exit_class", Message.SignalTiming.DISAPPEAR, ["res://school/Lunchroom.tscn", Vector2i(-1, -27)], null, teacher_portrait)
]

var intro_prompt = Game.Prompt.new("Introduce yourself to the class:", "map_intro", "countdown", 60.0, false, {"big": "My name is...and I..."})
var transfer_students = []
var transfer_student_index = 0
var submitted_intros = 0
var all_intros_submitted = false

func _ready():
	connect("exit_class", _exit_class)
	connect("wait_for_intro", _wait_for_intro)
	connect("map_intro", _intro)
	connect("intro_finished", _intro_finished)
	Game.SendPromptToUsers(intro_prompt)

func init():
	camera.SetTarget(null)
	camera.transform.origin = Vector2(90, 90)
	var world = get_parent()
	world.PauseWorld()
	world.SetMessageQueue(pre_intro_messages, false)
	
	for ip in Game.users:
		if ip != Game.HOST_IP:
			transfer_students.append(Game.users[ip])

func _wait_for_intro(args):
	if all_intros_submitted:
		UI.background.visible = true
		get_intro()
	else:
		await intros_submitted
		UI.background.visible = true
		get_intro()

func get_intro():
	# A delay is needed when switching queues on a signal due to the World process
	await get_tree().create_timer(1.0).timeout
	var student = transfer_students[transfer_student_index]
	get_parent().SetMessageQueue(intro_messages[student.character_data.name], false)
	transfer_student_index += 1

func _intro_finished(args):
	if transfer_student_index < Game.users.size() - 1:
		get_intro()
	else:
		await get_tree().create_timer(1.0).timeout
		UI.background.visible = false
		get_parent().SetMessageQueue(post_intro_messages, false)

func _exit_class(args):
	get_parent().emit_signal("portal_entered", args[0], args[1])

func _intro(packet):
	var user = Game.users[packet["userIP"]]
	Game.SendPromptToUser(Game.wait_prompt, packet["userIP"])
	var user_intro_messages = intro_messages[user.character_data.name]
	for message in user_intro_messages:
		if message.content == "INTRO":
			message.content = packet["bigInputValue"]
			break
	submitted_intros += 1
	if submitted_intros == Game.users.size() - 1:
		emit_signal("intros_submitted")
		all_intros_submitted = true

func update(delta):
	pass
