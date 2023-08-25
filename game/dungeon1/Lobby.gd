extends Map

signal all_players_joined
signal chest_sound

func _ready():
	$OutsideDoor.SetLockStatus(false)
	connect("chest_sound", _chest_sound)
	connect("all_players_joined", _allPlayersJoined)
	set_process(false)

func _allPlayersJoined():
	$OutsideDoor.SetLockStatus(false)
	$PointLight2D.energy *= 1.5
	
func _chest_sound(character, object):
	print("did it!")
	$Chest/ChestSound.play()
