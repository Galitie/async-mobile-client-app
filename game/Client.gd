extends Node2D

signal addedToDB
signal attemptJoin
signal addPlayer
signal disconnect
signal sendText
signal sayCatchphrase
signal emote

var websocket_url = "wss://13z2e6ro4l.execute-api.us-west-2.amazonaws.com/prod/"
var socket = WebSocketPeer.new()

var initial_connection = true
var users = {}

enum CONNECTION_STATUS {ONLINE, OFFLINE}

@onready var game_handle = $World

class UserData:
	var ip
	var name
	var role
	var connection_id
	var catchphrase
	var connection_status

func _ready():
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		print('Websocket is connected')
	
	connect("addedToDB", _addedToDB)
	connect("attemptJoin", _attemptJoin)
	connect("disconnect", _disconnect)
	connect("sendText", _sendText)
	connect("addPlayer", _addPlayer)
	connect("sayCatchphrase", _sayCatchPhrase)
	connect("emote", _emote)
	
func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if initial_connection:
			SendPacket({"action": "addUserToDB", "role": "host"})
			initial_connection = false
			
		while socket.get_available_packet_count():
			ProcessPacket(socket.get_packet())
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.

func SendPacket(data):
	var packet_data = JSON.stringify(data)
	var err = socket.send_text(packet_data)
	if err != OK:
		print("Unable to send packet: " + packet_data)
		
func ProcessPacket(packet):
	var packet_str = packet.get_string_from_utf8()
	var json_packet = JSON.parse_string(packet_str)
	print(json_packet)
	emit_signal(json_packet["message"], json_packet)

################### Signals ###################

func _addedToDB(packet):
	game_handle.ready_for_players = true

func _attemptJoin(packet):
	var response = {"action": "respondToUser", "connectionID": packet["connectionID"]}
	if users.has(packet["userIP"]):
		var user = users[packet["userIP"]]
		user.connection_id = packet["connectionID"]
		user.connection_status = CONNECTION_STATUS.ONLINE
		game_handle.UpdateUserData(user)
		print(user.name + " has reconnected")
		response["message"] = "reconnect"
		response.merge(game_handle.world_prompt.data)
	else:
		if game_handle.ready_for_players && game_handle.players.size() < game_handle.MAX_PLAYERS:
			response.merge(game_handle.create_character_prompt.data)
		else:
			response["message"] = "refuseJoin"
	SendPacket(response)

func _addPlayer(packet):
	var user_data = UserData.new()
	user_data.ip = packet["userIP"]
	user_data.name = packet["smallInputValue"]
	user_data.role = "user"
	user_data.connection_id = packet["connectionID"]
	user_data.catchphrase = packet["bigInputValue"]
	user_data.connection_status = CONNECTION_STATUS.ONLINE
	users[user_data.ip] = user_data
	game_handle.AddPlayer(user_data, game_handle.players.size())
	game_handle.SpawnCharacter(game_handle.players[user_data.ip], game_handle.players[game_handle.last_ip].character, game_handle.players["0.0.0.0"].character.cell_position)
	print(user_data.name + " has joined the game")
	SendPacket({"action": "addUserToDB", "role": user_data.role, "userIP": packet["userIP"], "connectionID": packet["connectionID"]})
	var user_packet = {"action": "respondToUser", "connectionID": packet["connectionID"]}
	user_packet.merge(game_handle.world_prompt.data)
	SendPacket(user_packet)
	
func _disconnect(packet):
	if users.has(packet["userIP"]):
		users[packet["userIP"]].connection_status = CONNECTION_STATUS.OFFLINE
		game_handle.UpdateUserData(users[packet["userIP"]])
		print(users[packet["userIP"]].name + " has left the game")

func _sendText(packet):
	if users.has(packet["userIP"]):
		game_handle.ParseContext(packet)
	else:
		emit_signal(packet["context"], packet)

func _sayCatchPhrase(packet):
	if users.has(packet["userIP"]):
		game_handle.Speak(packet["userIP"], users[packet["userIP"]].catchphrase)

func _emote(packet):
	if users.has(packet["userIP"]):
		game_handle.Emote(packet["userIP"], packet["emoji"])
