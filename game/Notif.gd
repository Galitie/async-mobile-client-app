extends RichTextLabel

@onready var timer = $Timer
@onready var sfx = $SFX
@onready var animation_player = $AnimationPlayer

func _ready():
	timer.connect("timeout", _timeOut)
	set_process(false)
	
func Appear():
	visible = true
	sfx.play()
	animation_player.play("blink")
	timer.start()
	
func _timeOut():
	visible = false
