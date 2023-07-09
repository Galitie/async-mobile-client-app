# BUG: Speaker name does not show if there is no icon
# BUG: Icon texture on TTS message is blown up if talking to an icon-less speaker
# BUG: UI in windowed mode on Galit's device does not scale
# BUG/TODO: Characters need to be put on the same layer as map objects for proper Y sorting
# BUG/TODO: Camera visibly moves between room transitions rather than being set
# TODO: Message box animations
# TODO: Reset method for box rooms
# TODO: Create proper states for the world (reading, battling, etc)
# TODO: Revamp movement system. Tweens and timers will not cut it
extends Node2D

var state = null
var previous_state
var users = {}
var ready_for_players = false
const HOST_IP = "0.0.0.0"
const MAX_PLAYERS = 5

const map_cell_size = 16
const collision_layer = 3

# TTS voices need to be installed from either the Windows speech package downloader in settings or from the
# runtime here: https://www.microsoft.com/en-us/download/details.aspx?id=27224
# Then the registry key for each voice needs to be exported, and their paths changed from OneSpeech to
# Speech and reimported in order to be recognized by Godot
@onready var voices = DisplayServer.tts_get_voices()

func ChangeState(end_state, start_state):
	end_state.emit_signal("end_state")
	start_state.emit_signal("start_state")
	Game.state = start_state
	Game.previous_state = end_state

class UserData:
	var ip
	var name
	var role
	var connection_id
	var catchphrase
	var connection_status
	var voice_id
	var character_data

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
