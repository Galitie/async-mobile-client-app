extends Node2D

signal start_state
signal end_state

signal user_reconnected
signal user_joined
signal user_disconnected
signal sent_text
signal add_user
signal emote

signal portal_entered
signal speak

var character_manifest = [
	"res://characters/tyler.tres",
	"res://characters/mario.tres",
	"res://characters/snake.tres",
	"res://characters/shrek.tres",
	"res://characters/kermit.tres"
]

var current_map
var paused = false
var last_ip
var current_message = null
var reading = false
var message_queue = []
var tts_queue = []

@onready var create_character_prompt = Game.Prompt.new("Add player to game:", "add_user", "countdown", 0.0, false, {"big": "Enter a signature catchphrase.", "small": "Enter your name."})
@onready var world_prompt = Game.Prompt.new("Say something to Tyler!", "speak", "cooldown", 10.0, true, {"big": "Say something EXTREMELY helpful to Tyler."})

class TTSMessage:
	var content
	var voice_id
	var pitch
	var speaker_name
	var icon_region

var characters = {}

var next_map
var spawn_position
var battle = false

@onready var message_box = $Camera2D/CanvasLayer/UI/MessageBox

func _ready():
	Game.state = self
	
	connect("start_state", _startState)
	connect("end_state", _endState)
	connect("user_reconnected", _userReconnected)
	connect("user_joined", _userJoined)
	connect("user_disconnected", _userDisconnected)
	connect("sent_text", _sentText)
	connect("add_user", _addUser)
	connect("emote", _emote)
	connect("speak", _speak)
	connect("portal_entered", _portalEntered)
	
	var lobby_map = preload("res://dungeon1/Lobby.tscn") as PackedScene
	current_map = lobby_map.instantiate()
	add_child(current_map)
	
	var host_data = Game.UserData.new()
	host_data.ip = Game.HOST_IP
	host_data.name = "Tyler"
	host_data.catchphrase = "..."
	host_data.role = "host"
	host_data.connection_id = "0"
	host_data.connection_status = Client.CONNECTION_STATUS.ONLINE
	characters[host_data.ip] = CreateCharacter(0)
	host_data.character_data = characters[host_data.ip]
	host_data.voice_id = GetVoiceID(characters[host_data.ip])
	Game.users[host_data.ip] = host_data
	last_ip = host_data.ip
	
	SpawnCharacter(characters[host_data.ip], Vector2i(-1, 0))
	$Camera2D.SetTarget(characters[host_data.ip])
	
func SpawnCharacter(character, cell_position):
	character.SetCellPosition(cell_position)
	character.visible = true
	
func GetVoiceID(character):
	for voice in Game.voices:
		if voice["name"] == character.character_data.tts_name:
			return voice["id"]
	return Game.voices[0]["id"]
	
func CreateCharacter(character_index):
	var character_data = ResourceLoader.load(character_manifest[character_index])
	var character_scene = load("res://Characters/Character.tscn") as PackedScene
	var character = character_scene.instantiate()
	character.visible = false
	$Party.add_child(character)
	character.Init(self, character_data)
	return character
		
func _userReconnected(packet):
	if characters.has(packet["userIP"]):
		characters[packet["userIP"]].modulate = Color.WHITE
		
		Game.SendPromptToUser(world_prompt, packet["userIP"])
	
func _userDisconnected(packet):
	if characters.has(packet["userIP"]):
		characters[packet["userIP"]].modulate = Color.DIM_GRAY

func _sentText(packet):
	if packet["context"].substr(0, 3) == "map":
		current_map.emit_signal(packet["context"], packet)
	else:
		emit_signal(packet["context"], packet)

func ParseContext(packet):
	if is_connected(packet["context"], Callable(self, "_" + packet["context"])):
		emit_signal(packet["context"], packet)
	elif current_map.is_connected(packet["context"], Callable(current_map, "_" + packet["context"])):
		current_map.emit_signal(packet["context"], packet)

func _speak(packet):
	var tts_msg = TTSMessage.new()
	tts_msg.content = packet["bigInputValue"]
	tts_msg.voice_id = Game.users[packet["userIP"]].voice_id
	tts_msg.pitch = Game.users[packet["userIP"]].character_data.voice_pitch
	tts_msg.speaker_name = Game.users[packet["userIP"]].character_data.name
	tts_msg.icon_region = Game.users[packet["userIP"]].character_data.icon_region
	tts_queue.append(tts_msg)
	
func _userJoined(packet):
	# Packet is returned merged with the character creation prompt because no user has been
	# established yet.
	packet.merge(create_character_prompt.data)
	Client.SendPacket(packet)
	
func _addUser(packet):
	if Game.ready_for_players:
		var user_data = Game.UserData.new()
		user_data.ip = packet["userIP"]
		user_data.name = packet["smallInputValue"]
		user_data.role = "user"
		user_data.connection_id = packet["connectionID"]
		user_data.catchphrase = packet["bigInputValue"]
		user_data.connection_status = Client.CONNECTION_STATUS.ONLINE
		
		characters[user_data.ip] = CreateCharacter(characters.size())
		user_data.character_data = characters[user_data.ip].character_data
		user_data.voice_id = GetVoiceID(characters[user_data.ip])
		Game.users[user_data.ip] = user_data
		
		characters[last_ip].follower = characters[user_data.ip]
		SpawnCharacter(characters[user_data.ip], characters[last_ip].cell_position)
		last_ip = user_data.ip
		
		print(user_data.name + " has joined the game")
		Client.SendPacket({"action": "addUserToDB", "role": user_data.role, "userIP": user_data.ip, "connectionID": user_data.connection_id})
		
		Game.SendPromptToUser(world_prompt, user_data.ip)
	else:
		var response = {"action": "respondToUser", "message": "refuseJoin", "connectionID": packet["connectionID"]}
		Client.SendPacket(response)
	
func _emote(packet):
	if Game.users.has(packet["userIP"]):
		characters[packet["userIP"]].Emote(packet["emoji"])
	
func _process(delta):
	if !paused:
		# First party member is controllable
		$Party.get_child(0).Update(delta)
		current_map.update(delta)
		
		if !DisplayServer.tts_is_speaking():
			if tts_queue.size():
				var tts = tts_queue.pop_front()
				DisplayServer.tts_speak(tts.content, tts.voice_id, 50, tts.pitch)
				message_box.Show(tts.content, tts.speaker_name, tts.icon_region)
			elif message_box.showing:
				message_box.Hide()
	elif reading && Input.is_action_just_pressed("interact"):
		if current_message.signal_timing == Message.SignalTiming.DISAPPEAR:
			current_map.emit_signal(current_message.message_signal, current_message.message_args)
		current_message = message_queue.pop_front()
		if current_message == null:
			message_box.Hide()
			reading = false
			if !battle:
				ResumeWorld()
		else:
			message_box.SetText(true, current_message.content, current_message.speaker)
			if current_message.signal_timing == Message.SignalTiming.APPEAR:
				current_map.emit_signal(current_message.message_signal, current_message.message_args)

func SetMessageQueue(messages):
	PauseWorld()
	reading = true
	message_queue = messages.duplicate()
	current_message = message_queue.pop_front()
	message_box.Show(current_message.content, current_message.speaker)
	if current_message.signal_timing == Message.SignalTiming.APPEAR:
		current_map.emit_signal(current_message.message_signal, current_message.message_args)
	
func _portalEntered(_next_map, _spawn_position):
	Game.ready_for_players = false
	PauseWorld()
	next_map = _next_map
	spawn_position = _spawn_position
	Transition.get_node("AnimationPlayer").play("fade_out")
	await get_tree().create_timer(0.4).timeout
	remove_child(current_map)
	current_map = load(next_map).instantiate()
	add_child(current_map)
	for member in $Party.get_children():
		member.SetCellPosition(spawn_position)
	next_map = null
	spawn_position = Vector2i.ZERO
	$Camera2D.transform.origin = characters[Game.HOST_IP].transform.origin
	Transition.get_node("AnimationPlayer").play("fade_in")
	await get_tree().create_timer(0.4).timeout
	ResumeWorld()

func PauseWorld():
	paused = true
	DisplayServer.tts_pause()
	
func ResumeWorld():
	paused = false
	DisplayServer.tts_resume()

func StartBattle(battle_args):
	Game.SendPromptToUsers(Game.wait_prompt)
	
	battle = true
	Transition.get_node("AnimationPlayer").play("fade_out")
	await get_tree().create_timer(0.4).timeout
	var battle_scene = load("res://battle/Battle.tscn") as PackedScene
	var battle_instance = battle_scene.instantiate()
	battle_instance.enemy_info = ResourceLoader.load(battle_args[0])
	get_tree().root.add_child(battle_instance)
	Game.ChangeState(self, battle_instance)
	Transition.get_node("AnimationPlayer").play("fade_in")
	await get_tree().create_timer(0.4).timeout
	
func _startState():
	visible = true
	battle = false
	for user in Game.users:
		if Game.users[user].connection_status == Client.CONNECTION_STATUS.ONLINE:
			characters[Game.users[user].ip].modulate = Color.WHITE
		elif Game.users[user].connection_status == Client.CONNECTION_STATUS.OFFLINE:
			characters[Game.users[user].ip].modulate = Color.DIM_GRAY
	Game.SendPromptToUsers(world_prompt)
	ResumeWorld()
	
func _endState():
	PauseWorld()
	visible = false
