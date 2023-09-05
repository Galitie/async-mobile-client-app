extends Node2D

signal addedToDB
signal attemptJoin
signal addPlayer
signal disconnect
signal sendText

var websocket_url = "wss://13z2e6ro4l.execute-api.us-west-2.amazonaws.com/prod/"
var socket = WebSocketPeer.new()

var initial_connection = true
enum CONNECTION_STATUS {ONLINE, OFFLINE}

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
	Game.ready_for_players = true

func _attemptJoin(packet):
	var response = {"action": "respondToUser", "connectionID": packet["connectionID"]}
	if Game.ready_for_players:
		response.merge(Game.create_character_prompt.data)
	else:
		response["message"] = "refuseJoin"
	SendPacket(response)

func _addPlayer(packet):
	Game.state.emit_signal("character_created", packet)
	
func _disconnect(packet):
	if Game.users.has(packet["userIP"]):
		Game.users[packet["userIP"]].connection_status = CONNECTION_STATUS.OFFLINE
	Game.state.emit_signal("user_disconnected", packet)

func _sendText(packet):
	Game.state.emit_signal("sent_text", packet)
