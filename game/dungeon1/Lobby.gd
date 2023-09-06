extends Map

signal all_players_joined
signal chest_sound
signal map_confirm_all_players_in_game

func _ready():
	$OutsideDoor.locked = true
	connect("chest_sound", _chest_sound)
	connect("all_players_joined", _allPlayersJoined)
	connect("map_confirm_all_players_in_game", _confirm_all_players_in_game)

func _process(delta):
	if UI.drop_box.visible:
		if Input.is_action_just_pressed("move_down"):
			UI.drop_box.MoveCursor(UI.drop_box.CursorPosition.DOWN)
		elif Input.is_action_just_pressed("move_up"):
			UI.drop_box.MoveCursor(UI.drop_box.CursorPosition.UP)
		if Input.is_action_just_pressed("interact"):
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
	UI.drop_box.visible = true
