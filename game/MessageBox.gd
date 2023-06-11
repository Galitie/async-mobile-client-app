extends TextureRect

var showing = false
var awaiting_message = false
var message
var info
var speaker_name
var icon_region

func _ready():
	$AnimationPlayer.connect("animation_started", _animationStarted)
	$AnimationPlayer.connect("animation_finished", _animationFinished)

func Show(content, _speaker_name = "", _icon_region = null):
	message = content
	speaker_name = _speaker_name
	icon_region = _icon_region
	if showing:
		Hide()
		awaiting_message = true
	else:
		$AnimationPlayer.play("appear")
	
func Hide():
	if showing:
		$Info.visible = false
		$Icon.visible = false
		$Dialogue.visible = false
		$AnimationPlayer.play("disappear")

func _animationStarted(anim):
	if anim == "appear":
		if speaker_name:
			$Dialogue.text = message
			$Icon.texture.region = icon_region
			$Icon/Name.text = "[center]" + speaker_name
		else:
			$Info.text = "[center]" + message

func _animationFinished(anim):
	if anim == "appear":
		showing = true
		if speaker_name:
			$Dialogue.visible = true
			$Icon.visible = true
		else:
			$Info.visible = true
	elif anim == "disappear":
		if awaiting_message:
			$AnimationPlayer.play("appear")
			awaiting_message = false
		else:
			showing = false
