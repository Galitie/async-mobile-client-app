extends Marker2D

@onready var label = get_node("Label")
@onready var tween  = get_tree().create_tween()

var content = ""

func _ready():
	label.set_text(str(content))
	tween.tween_property(self, "scale", Vector2(.7,.7), 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(.1,.1), .5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT).set_delay(0.2)
	tween.tween_callback(self.queue_free)

func _process(delta):
	position -= Vector2(0, 10) * delta
