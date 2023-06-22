extends TileMap

signal chestOpened

var chest_opened_before = false


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("chestOpened", _chestOpened)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _chestOpened():
	if chest_opened_before:
		print('Chest has been opened before')
		
	else:
		print('This is the first chest ever')
		chest_opened_before = true
		
