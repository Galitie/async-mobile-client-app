extends Node2D

var characters = [
	"res://characters/tyler.tres",
	"res://characters/mario.tres",
	"res://characters/tyler.tres"
]

var client
var ready_for_players = false
var current_map
var party_members = []

func _ready():
	client = get_parent()
	var lobby_map = preload("res://Lobby.tscn") as PackedScene
	current_map = lobby_map.instantiate()
	add_child(current_map)
	
	var host_data = client.UserData.new()
	host_data.ip = "0.0.0.0"
	host_data.name = "Tyler"
	host_data.catchphrase = "..."
	host_data.role = "host"
	host_data.connection_id = "0"
	host_data.connection_status = client.CONNECTION_STATUS.ONLINE
	CreateCharacter(host_data)
	
func CreateCharacter(user_data):
	var character_data = ResourceLoader.load(characters[party_members.size()])
	var character_scene = load("res://Characters/Character.tscn") as PackedScene
	var character = character_scene.instantiate()
	$Characters.add_child(character)
	var is_player = true if !party_members.size() else false
	party_members.append(character)
	var behind_character = null
	var cell_position = Vector2i(-1, 0)
	if !is_player:
		party_members[party_members.size() - 2].follower = character
		cell_position = party_members.front().cell_position
	character.Init(self, character_data, user_data, is_player, cell_position)
	
func UpdateUserData(user_data):
	for member in party_members:
		if member.user_data.ip == user_data.ip:
			member.user_data = user_data
			if member.user_data.connection_status == client.CONNECTION_STATUS.ONLINE:
				member.modulate = Color.WHITE
			elif member.user_data.connection_status == client.CONNECTION_STATUS.OFFLINE:
				member.modulate = Color.DIM_GRAY
