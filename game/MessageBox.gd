extends TextureRect

var showing = false
var awaiting_message = false
var message
var info
var speaker_name
var icon_region
var timed = false

func _ready():
	$AnimationPlayer.connect("animation_finished", _animationFinished)

func Show(content, _speaker_name = "", _icon_region = null, _timed = false):
	timed = _timed
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
		$MoeTexture.visible = false
		$gateKeeperTexture.visible = false
		$Dialogue.visible = false
		$Name.visible = false
		$AnimationPlayer.play("disappear")
		UI.left_speaker.visible = false
		UI.right_speaker.visible = false
	
func SetText(explicit, content, _speaker_name = "", _icon_region = null):
	message = content
	speaker_name = _speaker_name
	icon_region = _icon_region if _icon_region != null else Rect2(0, 0, 0, 0)
	if explicit:
		if _speaker_name:
			print(_speaker_name)
			$Dialogue.text = message
			$Icon.texture.region = icon_region
			$Icon.visible = true
			if _speaker_name == "Foe" or _speaker_name == "Moe":
				$MoeTexture.visible = true
			if _speaker_name == "GateKeeper":
				$gateKeeperTexture.visible = true
			$Name.text = "[center]" + speaker_name
			$Name.visible = true
			$Dialogue.visible = true
			UI.left_speaker.visible = true
			UI.right_speaker.visible = true
		else:
			$Name.visible = false
			$Info.text = "[center]" + message
			$Info.visible = true
			$Dialogue.visible = false

func _animationFinished(anim):
	if anim == "appear":
		showing = true
		SetText(true, message, speaker_name, icon_region)
		if !timed:
			$AnimationPlayer.play("idle")
	elif anim == "disappear":
		if awaiting_message:
			$AnimationPlayer.play("appear")
			awaiting_message = false
		else:
			showing = false
