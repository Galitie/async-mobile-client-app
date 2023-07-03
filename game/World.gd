# BUG: Speaker name does not show if there is no icon
# BUG: Icon texture on TTS message is blown up if talking to an icon-less speaker
# BUG: UI in windowed mode on Galit's device does not scale
# BUG: Transition fade does not adapt to different screen sizes
# BUG/TODO: Characters need to be put on the same layer as map objects for proper Y sorting
# BUG/TODO: Camera visibly moves between room transitions rather than being set
# BUG: MessageBox on its first appearance sometimes has no appear animation
# TODO: Reset method for box rooms
# TODO: Create proper states for the world (reading, battling, etc)
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
var current_message = null
var reading = false
var message_queue = []
var tts_queue = []

class Prompt:
	var data = {
		"message": "prompt",
		"header": "Default header",
		"context": "default",
		"timerType": "none", # none, cooldown, countdown
		"timer": 0.0,
		"emojis": false,
		"inputs": {} # "big" and/or "small" keys with placeholder values
	}
	
	func _init(header, context, timerType, timer, emojis, inputs):
		data["header"] = header
		data["context"] = context
		data["timerType"] = timerType
		data["timer"] = timer
		data["emojis"] = emojis
		data["inputs"] = inputs

var create_character_prompt = Prompt.new("Add player to game:", "addPlayer", "countdown", 10.0, false, {"big": "Enter a signature catchphrase.", "small": "Enter your name."})
var world_prompt = Prompt.new("Say something to Tyler!", "speak", "cooldown", 10.0, true, {"big": "Say something EXTREMELY helpful to Tyler."})

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

const MAX_PLAYERS = 5
var players = {}

var next_map
var spawn_position
var battle = false

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
	elif current_map.is_connected(packet["context"], Callable(current_map, "_" + packet["context"])):
		current_map.emit_signal(packet["context"], packet)

func _speak(packet):
	var tts_msg = TTSMessage.new()
	tts_msg.content = packet["bigInputValue"]
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
		if current_message.signal_timing == Message.SignalTiming.DISAPPEAR:
			current_map.emit_signal(current_message.message_signal)
		current_message = message_queue.pop_front()
		if current_message == null:
			$CanvasLayer/MessageBox.Hide()
			reading = false
			if !battle:
				ResumeWorld()
		else:
			$CanvasLayer/MessageBox.SetText(true, current_message.content, current_message.speaker)
			if current_message.signal_timing == Message.SignalTiming.APPEAR:
				current_map.emit_signal(current_message.message_signal)

func SetMessageQueue(messages):
	PauseWorld()
	reading = true
	message_queue = messages.duplicate()
	current_message = message_queue.pop_front()
	$CanvasLayer/MessageBox.Show(current_message.content, current_message.speaker)
	if current_message.signal_timing == Message.SignalTiming.APPEAR:
		current_map.emit_signal(current_message.message_signal)
	
func _portalEntered(_next_map, _spawn_position):
	PauseWorld()
	next_map = _next_map
	spawn_position = _spawn_position
	$CanvasLayer/AnimationPlayer.play("fade_out")
	await get_tree().create_timer(0.4).timeout
	remove_child(current_map)
	current_map = load(next_map).instantiate()
	add_child(current_map)
	for ip in players:
		players[ip].character.SetCellPosition(spawn_position)
	next_map = null
	spawn_position = Vector2i.ZERO
	await get_tree().create_timer(0.4).timeout
	ResumeWorld()
	
func _animationFinished(anim):
	if anim == "fade_out":
		$CanvasLayer/AnimationPlayer.play("fade_in")

func PauseWorld():
	paused = true
	DisplayServer.tts_pause()
	
func ResumeWorld():
	paused = false
	DisplayServer.tts_resume()

func StartBattle():
	PauseWorld()
	battle = true
	$CanvasLayer/AnimationPlayer.play("fade_out")
	await get_tree().create_timer(0.4).timeout
	var battle_scene = load("res://Battle.tscn") as PackedScene
	var battle_instance = battle_scene.instantiate()
	battle_instance.z_index = 5
	add_child(battle_instance)
	await get_tree().create_timer(0.4).timeout
