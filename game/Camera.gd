extends Camera2D

func update():
	#transform.origin = lerp(transform.origin, get_parent().get_node("Character").transform.origin, 0.2)
	transform.origin = get_parent().get_node("Character").transform.origin
