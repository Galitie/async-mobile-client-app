extends TileMap

signal chestOpened
signal poemEntry
signal talkedToGatekeeper
signal moveGatekeeper

const max_chests = 4
var chests_opened = 0
var poem = []

func _ready():
	connect("chestOpened", _chestOpened)
	connect("poemEntry", _poemEntry)
	connect("talkedToGatekeeper", _talkedToGatekeeper)
	connect("moveGatekeeper", _moveGatekeeper)
	set_process(false)

func _chestOpened():
	if !chests_opened:
		var packet = {"action": "messageAllUsers"}
		var poem_prompt = get_parent().Prompt.new("Think of a poetic line that ends in \"ing\"", "poemEntry", "countdown", 30.0, false, {"big": "Don't be shy!"})
		packet.merge(poem_prompt.data)
		get_parent().client.SendPacket(packet)
	
	chests_opened += 1

func _poemEntry(packet):
	poem.append(packet["bigInputValue"])
	var response = {"action": "respondToUser", "connectionID": packet["connectionID"]}
	response.merge(get_parent().world_prompt.data)
	get_parent().client.SendPacket(response)

func _talkedToGatekeeper():
	if chests_opened == max_chests:
		var dialogue : Array[Resource] = []
		for line in poem:
			var message = Message.new()
			message.speaker = "Gatekeeper"
			message.content = line
			dialogue.append(message)
		var parting_words = Message.new()
		parting_words.speaker = "Gatekeeper"
		parting_words.content = "Beautiful. You may pass."
		parting_words.signal_timing = Message.SignalTiming.DISAPPEAR
		parting_words.message_signal = "moveGatekeeper"
		dialogue.append(parting_words)
		$Objects/Gatekeeper.messages = dialogue

func _moveGatekeeper():
	$Objects/Gatekeeper.SetCellPosition($Objects/Gatekeeper.cell_position + Vector2i(1, 0), false)
