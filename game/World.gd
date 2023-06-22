# TODO: $disconnect route to inform all users if it came from the host
extends Node2D

signal portal_entered
signal speak

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

const MAX_PLAYERS = 3
var players = {}

var next_map
var spawn_position

func _ready():
	$CanvasLayer/AnimationPlayer.connect("animation_finished", _animationFinished)
	connect("speak", _speak)
	connect("portal_entered", _portalEntered)
	
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
	SpawnCharacter(players[host_data.ip], null, Vector2i(-1, 0))
	$Camera2D.SetTarget(players[host_data.ip].character)
	
func SpawnCharacter(player, character_to_follow, cell_position):
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
	
	if players.size() == MAX_PLAYERS:
		current_map.emit_signal("all_players_joined")
	
func CreateCharacter(character_index):
	var character_data = ResourceLoader.load(character_manifest[character_index])
	var character_scene = load("res://Characters/Character.tscn") as PackedScene
	var character = character_scene.instantiate()
	character.visible = false
	$Party.add_child(character)
	character.Init(self, character_data)
	return character
	
func UpdateUserData(user_data):
	var player = players[user_data.ip]
	player.user_data = user_data
	if user_data.connection_status == client.CONNECTION_STATUS.ONLINE:
		player.character.modulate = Color.WHITE
	elif user_data.connection_status == client.CONNECTION_STATUS.OFFLINE:
		player.character.modulate = Color.DIM_GRAY

func ParseContext(packet):
	if is_connected(packet["context"], Callable(self, "_" + packet["context"])):
		emit_signal(packet["context"], packet)
	elif is_connected(packet["context"], Callable(current_map, "_" + packet["context"])):
		current_map.emit_signal(packet["context"], packet)

func _speak(packet):
	var tts_msg = TTSMessage.new()
	tts_msg.content = packet["content"]
	tts_msg.voice_id = players[packet["userIP"]].voice_id
	tts_msg.pitch = players[packet["userIP"]].character.character_data.voice_pitch
	tts_msg.speaker_name = players[packet["userIP"]].character.character_data.name
	tts_msg.icon_region = players[packet["userIP"]].character.character_data.icon_region
	tts_queue.append(tts_msg)
	
func _process(delta):
	if !paused:
		# First party member is controllable
		$Party.get_child(0).Update(delta)
		
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

func SetMessageQueue(messages):
	PauseWorld()
	reading = true
	message_queue = messages.duplicate()
	var message = message_queue.pop_front()
	$CanvasLayer/MessageBox.Show(message)
	
func _portalEntered(_next_map, _spawn_position):
	PauseWorld()
	next_map = _next_map
	spawn_position = _spawn_position
	$CanvasLayer/AnimationPlayer.play("fade_out")
	
func _animationFinished(anim):
	if anim == "fade_out":
		remove_child(current_map)
		current_map = load(next_map).instantiate()
		add_child(current_map)
		for ip in players:
			players[ip].character.SetCellPosition(spawn_position)
		next_map = null
		spawn_position = Vector2i.ZERO
		$CanvasLayer/AnimationPlayer.play("fade_in")
	elif anim == "fade_in":
		ResumeWorld()

func PauseWorld():
	# client.SendPacket("action": "MessageAllUsers", "message": "pauseWorld")
	paused = true
	DisplayServer.tts_pause()
	
func ResumeWorld():
	# client.SendPacket("action": "MessageAllUsers", "message": "resumeWorld")
	paused = false
	DisplayServer.tts_resume()
