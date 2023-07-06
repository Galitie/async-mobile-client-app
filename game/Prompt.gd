class_name Global

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
