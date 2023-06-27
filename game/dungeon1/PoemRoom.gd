extends TileMap

signal chestOpened
signal poemEntry
signal talkedToGatekeeper
signal moveGatekeeper

const max_chests = 4
var chests_opened = 0
var poem = []
var moved = false

func _ready():
	connect("chestOpened", _chestOpened)
	connect("poemEntry", _poemEntry)
	connect("talkedToGatekeeper", _talkedToGatekeeper)
	connect("moveGatekeeper", _moveGatekeeper)
	set_process(false)

func _chestOpened(character, object):
	if !chests_opened:
		var packet = {"action": "messageAllUsers"}
		var poem_prompt = get_parent().Prompt.new("Think of a poetic line that ends in \"ing\"", "poemEntry", "countdown", 30.0, false, {"big": "Don't be shy!"})
		packet.merge(poem_prompt.data)
		get_parent().client.SendPacket(packet)
		chests_opened = 4
		
	#chests_opened += 1
	
	match chests_opened:
		1:
			object.messages.append(Message.new("", "You found a[color=yellow] scrap of paper."))
		2:
			object.messages.append(Message.new("", "You found another[color=yellow] scrap of paper."))
		3:
			object.messages.append(Message.new("", "One more[color=yellow] scrap of paper."))
		4:
			object.messages.append(Message.new("", "You got the last[color=yellow] scrap of paper."))

func _poemEntry(packet):
	poem.append(packet["bigInputValue"])
	var response = {"action": "respondToUser", "connectionID": packet["connectionID"]}
	response.merge(get_parent().world_prompt.data)
	get_parent().client.SendPacket(response)

func _talkedToGatekeeper(character, object):
	if !moved && chests_opened == max_chests:
		var dialogue : Array[Resource] = []
		for line in poem:
			var message = Message.new("Gatekeeper", line)
			dialogue.append(message)
		var parting_words = Message.new("Gatekeeper", "Beautiful. You may pass.", "moveGatekeeper", Message.SignalTiming.DISAPPEAR)
		dialogue.append(parting_words)
		object.messages = dialogue
		moved = true

func _moveGatekeeper():
	$Objects/Gatekeeper.SetCellPosition($Objects/Gatekeeper.cell_position + Vector2i(1, 0), false)
	var dialogue : Array[Resource] = []
	var message = Message.new("Gatekeeper", "Great job - seriously. You've moved me.")
	dialogue.append(message)
	$Objects/Gatekeeper.messages = dialogue
