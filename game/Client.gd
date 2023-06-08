extends Node2D

signal addedToDB
signal attemptJoin
signal disconnect
signal chat
signal createCharacter

var websocket_url = "wss://13z2e6ro4l.execute-api.us-west-2.amazonaws.com/prod/"
var socket = WebSocketPeer.new()

var initial_connection = true
var users = {}

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
	# {"action": "messageHost", "message": "createCharacter", "name": "Raam", "catchphrase": "Bazinga"}
		
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
	# Tell World to start game, load lobby, create host "Tyler" character, etc.
	pass

func _userAttemptedToJoin(packet):
	var response = {"action": "respondToUser", "connectionID": packet["connectionID"]}
	if users.has(packet["userIP"]):
		var user = users[packet["userIP"]]
		user.connection_id = packet["userID"]
		print(user.name + " has reconnected")
		response["message"] = "reconnect"
	else:
		if true: # Insert game check for lobby state here
			response["message"] = "requestJoin"
		else:
			response["message"] = "refuseJoin"
	SendPacket(response)

func _characterCreated(packet):
	# Create character in world -- what's below is most likely not how it will be done
	var user = User.UserItem.new()
	user.ip = packet["userIP"]
	user.name = packet["name"]
	user.connection_id = packet["userID"]
	user.role = packet["userRole"]
	user.connection_status = User.CONNECTION_STATUS.ONLINE
	users[user.ip] = user
	print(packet["name"] + " has joined the game")
	
func _userDisconnected(packet):
	if users.has(packet["userIP"]):
		users[packet["userIP"]].connection_status = User.CONNECTION_STATUS.OFFLINE
		print(users[packet["userIP"]].name + " has left the game")

func _userChatted(packet):
	if users.has(packet["userIP"]):
		users[packet["userIP"]].character.speak(packet["chat"])
