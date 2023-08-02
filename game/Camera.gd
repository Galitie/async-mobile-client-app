extends Camera2D

var target

func SetTarget(_target):
	target = _target

func _process(delta):
	if target != null:
		transform.origin = lerp(transform.origin, target.transform.origin, 0.2)
