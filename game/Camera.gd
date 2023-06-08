extends Camera2D

func _process(delta):
	transform.origin = lerp(transform.origin, get_parent().get_node("Characters/Character").transform.origin, 0.2)
