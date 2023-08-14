extends Label

@onready var timer = $Timer
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	visible = false

func playAnimation():
	position = Vector2(-170, -79)
	modulate = Color(255,255,255,255)
	visible = true
	text = str(rng.randi() % 100000)
	var tween = get_tree().create_tween()
	timer.start()
	tween.play()
	tween.tween_property(self, "position", Vector2(position.x, position.y - 10), 1)
	tween.tween_property(self, "modulate", Color(255,255,255, 0), .5 )

func _on_timer_timeout():
	visible = false
