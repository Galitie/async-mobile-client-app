extends Map

signal all_players_joined
signal chest_sound
signal map_confirm_all_players_in_game
#signal pushCrate

@onready var push_sound = $PushSound

func _ready():
	$OutsideDoor.locked = true
	connect("chest_sound", _chest_sound)
	connect("all_players_joined", _allPlayersJoined)
	connect("map_confirm_all_players_in_game", _confirm_all_players_in_game)
#	connect("pushCrate", _pushCrate)

func _process(delta):
	if UI.drop_box.visible:
		if Input.is_action_just_pressed("move_down"):
			UI.drop_box.MoveCursor(UI.drop_box.CursorPosition.DOWN)
			$CursorSound.play()
		elif Input.is_action_just_pressed("move_up"):
			UI.drop_box.MoveCursor(UI.drop_box.CursorPosition.UP)
			$CursorSound.play()
		if Input.is_action_just_pressed("interact"):
			$SelectedSound.play()
			var selected_option = UI.drop_box.SelectOption()
			if !selected_option:
				pass
			elif selected_option:
				$OutsideDoor.locked = false
				$Trigger.active = false
			UI.drop_box.visible = false
			get_parent().ResumeWorld()

func _allPlayersJoined():
	$PointLight2D.energy *= 1.5
	
func _chest_sound(character, object):
	$Chest/ChestSound.play()

class ReadyOption:
	func _init(_content):
		content = _content
	var content
	var ip

func _confirm_all_players_in_game(packet):
	UI.drop_box.SetOptions([ReadyOption.new("Not ready!"), ReadyOption.new("All players in!")])
	get_parent().PauseWorld()
	$TylerNotif.play()
	UI.drop_box.visible = true
	
#func _pushCrate(character, object):
#	var direction = Vector2i(0, 0)
#	match character.direction:
#		"north":
#			direction = Vector2i(0, -1)
#		"south":
#			direction = Vector2i(0, 1)
#		"east":
#			direction = Vector2i(1, 0)
#		"west":
#			direction = Vector2i(-1, 0)
#	var destination = object.cell_position + direction
#	var tile_data = get_cell_tile_data(Game.collision_layer, destination)
#	if tile_data:
#		return
#	for interactable in get_tree().get_nodes_in_group("interactables"):
#		if interactable.cell_position == destination:
#			return
#	object.SetCellPosition(destination, false)
#	push_sound.play()

