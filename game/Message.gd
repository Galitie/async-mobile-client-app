class_name Message
extends Resource

enum SignalTiming { NONE, APPEAR, DISAPPEAR }

@export var speaker : String
@export var content : String
@export var message_signal : String
@export var signal_timing : SignalTiming

func _init(_speaker = "", _content = "", _signal = "", _timing = SignalTiming.NONE):
	speaker = _speaker
	content = _content
	message_signal = _signal
	signal_timing = _timing
