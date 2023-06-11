extends Node2D

signal addedToDB
signal attemptJoin
signal createCharacter
signal disconnect
signal chat
signal sayCatchphrase

var websocket_url = "wss://13z2e6ro4l.execute-api.us-west-2.amazonaws.com/prod/"
var socket = WebSocketPeer.new()

var initial_connection = true
var users = {}

enum CONNECTION_STATUS {ONLINE, OFFLINE}

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
	connect("attemptJoin",  _userAttemptedToJoin)
	connect("disconnect", _userDisconnected)
	connect("chat", _userChatted)
	connect("createCharacter", _characterCreated)
	connect("sayCatchphrase", _userSaidCatchphrase)
	
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
	$World.ready_for_players = true

# { "action: messageHost", "message: attemptJoin" }
func _userAttemptedToJoin(packet):
	var response = {"action": "respondToUser", "connectionID": packet["connectionID"]}
	if users.has(packet["userIP"]):
		var user = users[packet["userIP"]]
		user.connection_id = packet["connectionID"]
		user.connection_status = CONNECTION_STATUS.ONLINE
		$World.UpdateUserData(user)
		print(user.name + " has reconnected")
		response["message"] = "reconnect"
	else:
		if $World.ready_for_players:
			response["message"] = "requestJoin"
		else:
			response["message"] = "refuseJoin"
	SendPacket(response)

# { "action": "messageHost", "message": "createCharacter", "name": "S", "catchphrase": "S" }
func _characterCreated(packet):
	var user_data = UserData.new()
	user_data.ip = packet["userIP"]
	user_data.name = packet["name"]
	user_data.role = "user"
	user_data.connection_id = packet["connectionID"]
	user_data.catchphrase = packet["catchphrase"]
	user_data.connection_status = CONNECTION_STATUS.ONLINE
	users[user_data.ip] = user_data
	$World.AddPlayer(user_data, $World.players.size())
	$World.SpawnCharacter($World.players[user_data.ip], false, $World.players[$World.last_ip].character, $World.players["0.0.0.0"].character.cell_position)
	print(user_data.name + " has joined the game")
	SendPacket({"action": "addUserToDB", "role": user_data.role, "userIP": packet["userIP"], "connectionID": packet["connectionID"]})
	
func _userDisconnected(packet):
	if users.has(packet["userIP"]):
		users[packet["userIP"]].connection_status = CONNECTION_STATUS.OFFLINE
		$World.UpdateUserData(users[packet["userIP"]])
		print(users[packet["userIP"]].name + " has left the game")

func _userChatted(packet):
	if users.has(packet["userIP"]):
		$World.Speak(packet["userIP"], packet["content"])

func _userSaidCatchphrase(packet):
	if users.has(packet["userIP"]):
		$World.Speak(packet["userIP"], users[packet["userIP"]].catchphrase)
