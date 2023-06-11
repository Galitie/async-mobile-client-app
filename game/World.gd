# TODO: Wipe users table on every addToDB packet
extends Node2D

var character_manifest = [
	"res://characters/tyler.tres",
	"res://characters/mario.tres",
	"res://characters/snake.tres",
	"res://characters/kermit.tres",
	"res://characters/shrek.tres"
]
var voices

var client
var ready_for_players = false
var current_map
var last_ip

class Player:
	var user_data
	var character
	var voice_id

var players = {}

func _ready():
	# TTS voices need to be installed from either the Windows speech package downloader in settings or from the
	# runtime here: https://www.microsoft.com/en-us/download/details.aspx?id=27224
	# Then the registry key for each voice needs to be exported, and their paths changed from OneSpeech to
	# Speech and reimported in order to be recognized by Godot
	voices = DisplayServer.tts_get_voices()
	
	var lobby_map = preload("res://Lobby.tscn") as PackedScene
	current_map = lobby_map.instantiate()
	add_child(current_map)
	
	client = get_parent()
	var host_data = client.UserData.new()
	host_data.ip = "0.0.0.0"
	host_data.name = "Tyler"
	host_data.catchphrase = "..."
	host_data.role = "host"
	host_data.connection_id = "0"
	host_data.connection_status = client.CONNECTION_STATUS.ONLINE
	var character = CreateCharacter(0)
	AddPlayer(host_data, players.size())
	SpawnCharacter(players[host_data.ip], true, null, Vector2i(-1, 0))
	
func SpawnCharacter(player, controllable, character_to_follow, cell_position):
	player.character.controllable = controllable
	player.character.SetCellPosition(cell_position)
	if character_to_follow:
		character_to_follow.follower = player.character
	last_ip = player.user_data.ip
	player.character.visible = true
	
func AddPlayer(user_data, character_index):
	var player = Player.new()
	player.user_data = user_data
	player.character = CreateCharacter(character_index)
	for voice in voices:
		if voice["name"] == player.character.character_data.tts_name:
			player.voice_id = voice["id"]
	players[player.user_data.ip] = player
	
func CreateCharacter(character_index):
	var character_data = ResourceLoader.load(character_manifest[character_index])
	var character_scene = load("res://Characters/Character.tscn") as PackedScene
	var character = character_scene.instantiate()
	character.visible = false
	$Characters.add_child(character)
	character.Init(self, character_data)
	return character
	
func UpdateUserData(user_data):
	var player = players[user_data.ip]
	player.user_data = user_data
	if user_data.connection_status == client.CONNECTION_STATUS.ONLINE:
		player.character.modulate = Color.WHITE
	elif user_data.connection_status == client.CONNECTION_STATUS.OFFLINE:
		player.character.modulate = Color.DIM_GRAY

func Speak(ip, chat_content):
	DisplayServer.tts_speak(chat_content, players[ip].voice_id, 50, players[ip].character.character_data.voice_pitch)
	$CanvasLayer/TextBox/Dialogue.text = chat_content
	$CanvasLayer/TextBox/Icon/Name.text = "[center]" + players[ip].character.character_data.name
	$CanvasLayer/TextBox/Icon.texture.region = players[ip].character.character_data.icon_region
	$CanvasLayer/TextBox/AnimationPlayer.play("appear")
	
func _process(delta):
	if !DisplayServer.tts_is_speaking() && $CanvasLayer/TextBox.visible:
		$CanvasLayer/TextBox/AnimationPlayer.play("disappear")
