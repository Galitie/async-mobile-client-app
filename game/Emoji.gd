extends Marker2D

@onready var particle = get_node("GPUParticles2D")

var content = ""

var emojis = {
	"love": 0.00,
	"sad": 0.50,
	"bee": 0.30,
	"wow": 1.00
	}

func _ready():
	particle.process_material.set("anim_offset_min", emojis[content])
	particle.process_material.set("anim_offset_max", emojis[content])
	particle.emitting = true
	if particle.emitting == false:
		self.queue_free()

func _process(delta):
	pass
