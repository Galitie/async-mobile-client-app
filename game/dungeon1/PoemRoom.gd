extends TileMap

signal chestOpened

var chest_opened_before = false

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("chestOpened", _chestOpened)
	set_process(false)

func _chestOpened():
	if !chest_opened_before:
		get_parent().client.SendPacket({"action": "messageAllUsers", "message": "prompt", "header": "Think of a poetic line that ends in \"ing\"", "context": "poemEntry", "timer": 30, "emojis": false})
		print('This is the first chest ever')
		chest_opened_before = true
	else:
		print('Chest has been opened before')
