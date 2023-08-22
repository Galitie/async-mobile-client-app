# BUG: Speaker name does not show if there is no icon
# BUG: Icon texture on TTS message is blown up if talking to an icon-less speaker
# TODO: Message box animations
# BUG: Controller interferes with keyboard movement
# TODO: Revamp movement system. Step timer does not sync properly in fullscreen
# TODO: Create proper states for the world (reading, battling, etc)
# BUG: Sending a TTS message with only punctuation leads to an empty message that shows up for
# a split second. Possibly add a minimum time limit to display the message?
# TODO: Music needs be edited to loop properly
# TODO: Victory music needs to transition back to previous BGM and BGM position
# TODO: Battle damage text
# BUG: Holding down a direction key at the end of Classroom teleports the player to a black void
# in the next map
extends Node2D

class UserData:
	var ip
	var name
	var role
	var connection_id
	var catchphrase
	var connection_status
	var voice_id
	var character_data
	var dice = 3
	var tyler_points = 0

class Prompt:
	var data = {
		"message": "prompt",
		"header": "Default header",
		"context": "default",
		"timerType": "none", # none, cooldown, countdown
		"timer": 0.0,
		"diceEnabled": false,
		"dice": 0,
		"inputs": {}, # "big" and/or "small" keys with placeholder values
		"style": "rpg" # "rpg" or "cute"
	}
	
	func _init(header, context, timerType, timer, diceEnabled, inputs, style = "rpg"):
		data["header"] = header
		data["context"] = context
		data["timerType"] = timerType
		data["timer"] = timer
		data["diceEnabled"] = diceEnabled
		data["inputs"] = inputs
		data["style"] = style

var state = null
var previous_state
var users = {}
var ready_for_players = false
const HOST_IP = "0.0.0.0"
const MAX_PLAYERS = 6

const map_cell_size = 16
const collision_layer = 3

var wait_prompt = Prompt.new("Please wait for other players to submit their response!", "wait", "none", 0.0, false, {"small": ""})

var winner_ip = ""
var villain_ip = ""

# TTS voices need to be installed from either the Windows speech package downloader in settings or from the
# runtime here: https://www.microsoft.com/en-us/download/details.aspx?id=27224
# Open registry editor app from start menu
# Search local machine for Speech and Speech_OneCore
# Then the registry key for each voice needs to be exported, and their paths changed from Speech_OneCore to
# Speech and reimported in order to be recognized by Godot
@onready var voices = DisplayServer.tts_get_voices()

@onready var bgm_player = AudioStreamPlayer.new()

func _ready():
	bgm_player.volume_db = -30.0
	add_child(bgm_player)

func ChangeState(end_state, start_state):
	end_state.emit_signal("end_state")
	start_state.emit_signal("start_state")
	state = start_state
	previous_state = end_state
	
func SendPromptToUsers(prompt, notify = true, exclude_villain = true):
	for user in users:
		if users[user].ip == HOST_IP:
			continue
		if exclude_villain && users[user].ip == villain_ip:
			continue
		SendPromptToUser(prompt, users[user].ip)
	if notify:
		UI.notif.Appear()

func SendPromptToUser(prompt, ip):
	if users[ip].connection_status == Client.CONNECTION_STATUS.ONLINE:
		var response = {"action": "respondToUser", "connectionID": users[ip].connection_id}
		response.merge(prompt.data)
		Client.SendPacket(response)
	elif users[ip].connection_status == Client.CONNECTION_STATUS.OFFLINE:
		if prompt.data["context"] != "wait" && prompt.data["context"] != "speak":
			var response = {"userIP": ip, "smallInputValue": "*blushes*", "bigInputValue": "*blushes*"}
			response.merge(prompt.data)
			state.emit_signal("sent_text", response)
