extends Map

signal startBattle
signal pushCrate
signal getMoneyFromChest


var music = load("res://dungeon1/dungeon.mp3")
@onready var push_sound = $PushSound
var money = UI.money_amount

func _ready():
	Game.bgm_player.stream = music
	Game.bgm_player.play()
	connect("startBattle", _startBattle)
	connect("pushCrate", _pushCrate)
	connect("getMoneyFromChest", _getMoneyFromChest)
	set_process(false)
	
func update(delta):
	if Input.is_action_just_pressed("restart"):
		get_parent().emit_signal("portal_entered", $RestartPortal.next_map, $RestartPortal.next_map_cell_position)

func _pushCrate(character, object):
	var direction = Vector2i(0, 0)
	match character.direction:
		"north":
			direction = Vector2i(0, -1)
		"south":
			direction = Vector2i(0, 1)
		"east":
			direction = Vector2i(1, 0)
		"west":
			direction = Vector2i(-1, 0)
	var destination = object.cell_position + direction
	var tile_data = get_cell_tile_data(Game.collision_layer, destination)
	if tile_data:
		return
	for interactable in get_tree().get_nodes_in_group("interactables"):
		if interactable.cell_position == destination:
			return
	object.SetCellPosition(destination, false)
	push_sound.play()

func _getMoneyFromChest(character, object):
	money.text = "10000000000"
	
func _startBattle(message_args):
	$Enemy.queue_free()
	get_parent().StartBattle(message_args)
