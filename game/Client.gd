extends Node2D

signal userJoined
signal userLeft
signal askToJoin

var websocket_url = "wss://13z2e6ro4l.execute-api.us-west-2.amazonaws.com/prod/"
var socket = WebSocketPeer.new()

var connected = false
var users = {}

func _ready():
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		print('Websocket is connected')
		
	connect("userJoined", Callable(self, "_onUserJoined"))
	connect("userLeft", Callable(self, "_onUserLeaves"))
	connect("askToJoin", Callable(self, "_onAskedToJoin"))
		
func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if !connected:
			SendPacket({"action": "join", "name": "Raam", "role": "host"})
			connected = true
			
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

func _onUserJoined(packet):
	# Update connection ID if user is rejoining the game
	if users.has(packet["userIP"]):
		users[packet["userIP"]].connection_id = packet["userID"]
		print(packet["userName"] + " has reconnected")
	else:
		var user = User.UserItem.new()
		user.ip = packet["userIP"]
		user.name = packet["userName"]
		user.connection_id = packet["userID"]
		user.role = packet["userRole"]
		user.connection_status = User.CONNECTION_STATUS.ONLINE
		users[user.ip] = user
		print(packet["userName"] + " has joined the game")
	print(users)
	
func _onUserLeaves(packet):
	if users.has(packet["userIP"]):
		users[packet["userIP"]].connection_status = User.CONNECTION_STATUS.OFFLINE
		print(packet["userName"] + " has left the game")

# Responds whether the game is in a state for connecting IPs to join as a user (such as a lobby)
func _onAskedToJoin(packet):
	var permission = true
	SendPacket({"action": "sendJoinPermission", "permission": permission, "connectionID": packet["connectionID"]})
