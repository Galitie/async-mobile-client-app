# TODO: $disconnect route to inform all users if it came from the host
extends Node2D

signal item_found

var character_manifest = [
	"res://characters/tyler.tres",
	"res://characters/mario.tres",
	"res://characters/snake.tres",
	"res://characters/shrek.tres",
	"res://characters/kermit.tres"
]
var voices

var client
var ready_for_players = false
var current_map
var paused = false
var last_ip
var reading = false
var message_queue = []
var tts_queue = []

class TTSMessage:
	var content
	var voice_id
	var pitch
	var speaker_name
	var icon_region

class Player:
	var user_data
	var character
	var voice_id

var players = {}

func _ready():
	connect("item_found", _itemFound)
	
	# TTS voices need to be installed from either the Windows speech package downloader in settings or from the
	# runtime here: https://www.microsoft.com/en-us/download/details.aspx?id=27224
	# Then the registry key for each voice needs to be exported, and their paths changed from OneSpeech to
	# Speech and reimported in order to be recognized by Godot
	voices = DisplayServer.tts_get_voices()
	
	var lobby_map = preload("res://dungeon1/Lobby.tscn") as PackedScene
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
	AddPlayer(host_data, players.size())
	SpawnCharacter(players[host_data.ip], true, null, Vector2i(-1, 0))
	$Camera2D.SetTarget(players[host_data.ip].character)
	
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
	var tts_msg = TTSMessage.new()
	tts_msg.content = chat_content
	tts_msg.voice_id = players[ip].voice_id
	tts_msg.pitch = players[ip].character.character_data.voice_pitch
	tts_msg.speaker_name = players[ip].character.character_data.name
	tts_msg.icon_region = players[ip].character.character_data.icon_region
	tts_queue.append(tts_msg)
	
func _process(delta):
	if !paused:
		if !DisplayServer.tts_is_speaking():
			if tts_queue.size():
				var tts = tts_queue.pop_front()
				DisplayServer.tts_speak(tts.content, tts.voice_id, 50, tts.pitch)
				$CanvasLayer/MessageBox.Show(tts.content, tts.speaker_name, tts.icon_region)
			elif $CanvasLayer/MessageBox.showing:
				$CanvasLayer/MessageBox.Hide()
	elif reading && Input.is_action_just_pressed("interact"):
		var next_message = message_queue.pop_front()
		if next_message == null:
			$CanvasLayer/MessageBox.Hide()
			reading = false
			ResumeWorld()
		else:
			$CanvasLayer/MessageBox.SetText(true, next_message)

func _itemFound(messages):
	PauseWorld()
	reading = true
	message_queue = messages
	var message = message_queue.pop_front()
	$CanvasLayer/MessageBox.Show(message)

func PauseWorld():
	# client.SendPacket("action": "MessageAllUsers", "message": "pauseWorld")
	paused = true
	DisplayServer.tts_pause()
	
func ResumeWorld():
	# client.SendPacket("action": "MessageAllUsers", "message": "resumeWorld")
	paused = false
	DisplayServer.tts_resume()
