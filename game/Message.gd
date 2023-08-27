class_name Message
extends Resource

enum SignalTiming { NONE, APPEAR, DISAPPEAR }

@export var speaker : String
@export var content : String
@export var message_signal : String
@export var message_args : Array
@export var signal_timing : SignalTiming

var left_speaker
var right_speaker
var icon_region

func _init(_speaker = "", _content = "", _signal = "", _timing = SignalTiming.NONE, _message_args = [], _left_speaker = null, _right_speaker = null, _icon_region = null):
	speaker = _speaker
	content = _content
	message_signal = _signal
	signal_timing = _timing
	message_args = _message_args
	left_speaker = _left_speaker
	right_speaker = _right_speaker
	icon_region = _icon_region
	
