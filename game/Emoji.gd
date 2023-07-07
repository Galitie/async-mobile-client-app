extends Marker2D

@onready var particle = get_node("GPUParticles2D")

var content = ""

func _ready():
	match content:
		"love":
			pass
		"bee":
			pass
		"cry":
			pass
		"wow":
			pass
			
	particle.emitting = true
	if particle.emitting == false:
		self.queue_free()

func _process(delta):
	pass
