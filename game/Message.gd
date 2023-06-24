class_name Message
extends Resource

enum SignalTiming { NONE, APPEAR, DISAPPEAR }

@export var speaker : String
@export var content : String
@export var message_signal : String
@export var signal_timing : SignalTiming
