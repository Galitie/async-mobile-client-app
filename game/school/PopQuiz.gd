extends Map

signal exit_class
signal map_intro
signal show_notes
signal start_question_input
signal map_question_submitted
signal present_question
signal question_answered
signal all_questions_answered
signal start_test

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
	Message.new("test", "Ok class, time for a pop quiz!", "start_question_input", Message.SignalTiming.APPEAR, [], null, teacher_portrait),
	Message.new("test", "Huh??", "start_test", Message.SignalTiming.DISAPPEAR, [], tyler_portrait, teacher_portrait)
]

var post_quiz_messages = [
	Message.new("test", "That's the bell!", "", Message.SignalTiming.NONE, [], null, teacher_portrait),
	Message.new("test", "It's time...I need to confront them...", "exit_class", Message.SignalTiming.DISAPPEAR, ["res://school/Lunchroom.tscn", Vector2i(-1, -27)], tyler_portrait, null)
]

var questions = [
	"What is Tyler's favorite thing to do?",
	"Where does Tyler live?",
	"What bank does Tyler use?",
	"What is Tyler's SSN?"
]

var question_prompts = [
	Game.Prompt.new(questions[0], "map_question_submitted", "countdown", 60.0, false, {"small": "私たちきですfun fun!!"}),
	Game.Prompt.new(questions[1], "map_question_submitted", "countdown", 60.0, false, {"small": "FULLHOUSEメです"}),
	Game.Prompt.new(questions[2], "map_question_submitted", "countdown", 60.0, false, {"small": "そのしrouting number?さい"}),
	Game.Prompt.new(questions[3], "map_question_submitted", "countdown", 60.0, false, {"small": "大好きだよthe Government"})
]
var question_index = 0
var answers_submitted = 0

class Answer:
	var content
	var ip
	
	func _init(_content, _ip):
		content = _content
		ip = _ip

var question_answers = [
	[],
	[],
	[],
	[]
]
 
var question_message = [
	Message.new("Sensei", "Question!", "present_question", Message.SignalTiming.DISAPPEAR, [], tyler_portrait, teacher_portrait)
]

func _ready():
	connect("exit_class", _exit_class)
	connect("show_notes", _show_notes)
	connect("start_question_input", _start_question_input)
	connect("map_question_submitted", _question_submitted)
	connect("present_question", _present_question)
	connect("start_test", _start_test)
	Game.SendPromptToUsers(Game.wait_prompt, false)

func init():
	UI.money.visible = false
	camera.SetTarget(null)
	camera.transform.origin = Vector2(90, 90)
	var world = get_parent()
	world.PauseWorld()
	world.SetMessageQueue(pre_note_messages, false)

func _show_notes(args):
	UI.love_note.get_node("Text").text = get_parent().love_notes[reaction_index]
	UI.love_note.visible = true
	reaction_index += 1

func _exit_class(args):
	get_parent().emit_signal("portal_entered", args[0], args[1])
	
func _start_question_input(args):
	Game.SendPromptToUsers(question_prompts[question_index], true)
	
func _question_submitted(packet):
	var answer = Answer.new(packet["smallInputValue"], packet["userIP"])
	question_answers[question_index].append(answer)
	answers_submitted += 1
	Game.SendPromptToUser(Game.wait_prompt, packet["userIP"])
	if answers_submitted >= Game.users.size() - 1:
		answers_submitted = 0
		question_index += 1
		if question_index > question_prompts.size() - 1:
			Game.SendPromptToUsers(Game.wait_prompt, false)
			emit_signal("all_questions_answered")
		else:
			Game.SendPromptToUsers(question_prompts[question_index], true)

func _start_test(args):
	if question_index <= question_prompts.size() - 1:
		await all_questions_answered
	question_index = 0
	await get_tree().create_timer(1.0).timeout
	get_parent().SetMessageQueue(question_message, false)

func _present_question(args):
	UI.left_speaker.texture = null
	UI.right_speaker.texture = teacher_portrait
	UI.message_box.Show(questions[question_index], "Sensei", null, true)
	UI.drop_box.SetOptions(question_answers[question_index])
	UI.drop_box.visible = true
	# To prevent the first question being skipped
	Input.action_release("interact")

func _process(delta):
	if UI.love_note.visible && Input.is_action_just_pressed("interact"):
		UI.love_note.visible = false
		if reaction_index >= get_parent().love_notes.size():
			get_parent().SetMessageQueue(pre_quiz_messages, false)
		else:
			get_parent().SetMessageQueue(note_reactions[reaction_index], false)
			
	if UI.drop_box.visible:
		if Input.is_action_just_pressed("move_down"):
			UI.drop_box.MoveCursor(UI.drop_box.CursorPosition.UP)
		elif Input.is_action_just_pressed("move_up"):
			UI.drop_box.MoveCursor(UI.drop_box.CursorPosition.UP)
		elif Input.is_action_just_pressed("interact"):
				var answer = question_answers[question_index][UI.drop_box.SelectOption()]
				question_index += 1
				if question_index <= question_answers.size() - 1:
					emit_signal("present_question", [])
				else:
					UI.message_box.Hide()
					UI.drop_box.visible = false
					get_parent().SetMessageQueue(post_quiz_messages, false)
