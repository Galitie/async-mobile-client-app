extends Node2D

func play():
	$AnimationPlayer.current_animation = "Supernova"
	$SuperNova2.play("default")
