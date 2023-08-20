extends Map

signal chestOpened
signal map_poem_entry
signal talkedToGatekeeper
signal moveGatekeeper
signal gatekeeper_speak

const max_chests = 4
var chests_opened = 0
var poem = []
var moved = false
var got_key = false

var open_chest_region = Rect2(145, 96, 17, 16)

var music = load("res://dungeon1/poem.mp3")

func _ready():
	Game.bgm_player.stream = music
	Game.bgm_player.play()
	connect("chestOpened", _chestOpened)
	connect("map_poem_entry", _poemEntry)
	connect("talkedToGatekeeper", _talkedToGatekeeper)
	connect("moveGatekeeper", _moveGatekeeper)
	connect("gatekeeper_speak", _gatekeeperSpeak)
	set_process(false)

func _chestOpened(character, object):
	if got_key:
		if !chests_opened:
			var poem_prompt = Game.Prompt.new("Write something poetic! It will be used later in the game!", "map_poem_entry", "countdown", 30.0, false, {"big": "Roses are red..."})
			Game.SendPromptToUsers(poem_prompt)
			
		chests_opened += 1
		object.messages.clear()
		object.one_shot = true
		object.region_rect = open_chest_region
		
		match chests_opened:
			1:
				object.messages.append(Message.new("", "You found a[color=yellow] blank scrap of paper."))
				object.messages.append(Message.new("", "Looks like you can write on it."))
			2:
				object.messages.append(Message.new("", "You found another[color=yellow] scrap of paper."))
			3:
				object.messages.append(Message.new("", "One more[color=yellow] scrap of paper."))
			4:
				object.messages.append(Message.new("", "You got the last[color=yellow] scrap of paper!"))

func _poemEntry(packet):
	poem.append(packet["bigInputValue"])
	Game.SendPromptToUser(get_parent().world_prompt, packet["userIP"])

func _talkedToGatekeeper(character, object):
	if !got_key:
		got_key = true
	elif got_key && chests_opened < max_chests:
		var dialogue : Array[Resource] = []
		dialogue.append(Message.new("Gatekeeper", "Hurry! My artistic whimsies are stagnant!"))
		object.messages = dialogue
	elif got_key && !moved && chests_opened == max_chests:
		var dialogue : Array[Resource] = []
		dialogue.append(Message.new("Gatekeeper", "Let's see what you have for me..."))
		for line in poem:
			dialogue.append(Message.new("Gatekeeper", line, "gatekeeper_speak", Message.SignalTiming.APPEAR, [line]))
		dialogue.append(Message.new("Gatekeeper", "Wow."))
		dialogue.append(Message.new("Gatekeeper", "The tears just won't stop!"))
		dialogue.append(Message.new("Gatekeeper", "I'm inspired -- truly."))
		dialogue.append(Message.new("Gatekeeper", "You shall pass.", "moveGatekeeper", Message.SignalTiming.DISAPPEAR))
		object.messages = dialogue
		moved = true
		
func _gatekeeperSpeak(message_args):
	DisplayServer.tts_speak(message_args[0], Game.voices[0]["id"], 50.0, 1.0)

func _moveGatekeeper(message_args):
	$Gatekeeper.SetCellPosition($Gatekeeper.cell_position + Vector2i(1, 0), false)
	var dialogue : Array[Resource] = []
	dialogue.append(Message.new("Gatekeeper", "That was so moving."))
	dialogue.append(Message.new("Gatekeeper", "Like, I'm all the way over here now!"))
	$Gatekeeper.messages = dialogue
