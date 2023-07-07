extends Sprite2D

@onready var timer = $Timer

class Emoji:
	var offset
	
	func _init(_offset):
		offset = _offset

var emojis = {
	"love": Emoji.new(Rect2(0, 0, 32, 32)),
	"bee": Emoji.new(Rect2(32, 0, 32, 32)),
	"sad": Emoji.new(Rect2(64, 0, 32, 32)),
	"wow": Emoji.new(Rect2(96, 0, 32, 32))
}

func _ready():
	timer.connect("timeout", _timeOut)
	visible = false

func Display(emoji):
	scale = Vector2(0.5, 0.5)
	timer.start()
	texture.region = emojis[emoji].offset
	visible = true
	
	var tween = get_tree().create_tween()
	tween.stop()
	tween.play()
	tween.tween_property(self, "scale", Vector2(0.7, 0.7), 0.5)
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.5)
	tween.set_loops(5)
	
func _timeOut():
	visible = false
