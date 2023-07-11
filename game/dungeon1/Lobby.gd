extends Map

signal all_players_joined

func _ready():
	$OutsideDoor.SetLockStatus(false)
	connect("all_players_joined", _allPlayersJoined)
	set_process(false)

func _allPlayersJoined():
	$OutsideDoor.SetLockStatus(false)
	$PointLight2D.energy *= 1.5
