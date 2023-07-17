extends TextureRect

var showing = false
var awaiting_message = false
var message
var info
var speaker_name
var icon_region

func _ready():
	$AnimationPlayer.connect("animation_finished", _animationFinished)

func Show(content, _speaker_name = "", _icon_region = null):
	SetText(false, content, _speaker_name, _icon_region)
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
	
func SetText(explicit, content, _speaker_name = "", _icon_region = null):
	message = content
	speaker_name = _speaker_name
	icon_region = _icon_region if _icon_region != null else Rect2(0, 0, 0, 0)
	if explicit:
		if _speaker_name:
			$Dialogue.text = message
			$Icon.texture.region = icon_region
			$Icon.visible = true
			$Icon/Name.text = "[center]" + speaker_name
			$Dialogue.visible = true
		else:
			$Info.text = "[center]" + message
			$Info.visible = true
			$Dialogue.visible = false

func _animationFinished(anim):
	if anim == "appear":
		showing = true
		SetText(true, message, speaker_name, icon_region)
	elif anim == "disappear":
		if awaiting_message:
			$AnimationPlayer.play("appear")
			awaiting_message = false
		else:
			showing = false
