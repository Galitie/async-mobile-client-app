extends TileMap

signal all_players_joined

func _ready():
	$Portals/OutsideDoor.SetLockStatus(true)
	connect("all_players_joined", _allPlayersJoined)
	set_process(false)

func _allPlayersJoined():
	$Portals/OutsideDoor.SetLockStatus(false)
	$PointLight2D.energy *= 1.5
