extends Map

signal final_battle
signal start_battle_music
signal cut_music
signal hearts_anim
signal angry_anim
signal sparkle_anim

var tyler_portrait = load("res://school/portraits/tyler.png")

var portraits = {
	"Mario" : load("res://school/portraits/mario.png"),
	"Kermit" : load("res://school/portraits/kermit.png"),
	"Snake" : load("res://school/portraits/snake.png"),
	"Shadow" : load("res://school/portraits/shadow.png"),
	"Shrek" : load("res://school/portraits/shrek.png")
}

var confessionBG = load("res://school/Outside_sakura_tree.png")
var confessionMusic = load("res://school/confessionMusic.mp3")
var final_battle_music = load("res://battle/finalBattle/final_battle.mp3")

@onready var sakuraPetals = $CanvasLayer/SakuraPetals
@onready var hearts = $CanvasLayer/Hearts
@onready var angry = $CanvasLayer/Angry
@onready var sparkle = $CanvasLayer/Sparkle
@onready var camera = get_parent().get_node("Camera2D")

# placeholder
var villain_portrait = null

var messages = [
	Message.new("Tyler", "Ok... I can do this!", "", Message.SignalTiming.NONE, [], tyler_portrait, null),
	Message.new("Tyler", "I'm so nervous, sugoi!!", "", Message.SignalTiming.NONE, [], tyler_portrait, null),
	Message.new("Tyler", "It's time to talk to *this* person about their love note...", "", Message.SignalTiming.NONE, [], tyler_portrait, null),
	Message.new("Tyler", "I bet this will go really well!!!!!!!", "sparkle_anim", Message.SignalTiming.APPEAR, [], tyler_portrait, null),
	Message.new("[VILLAIN]", "T-Tyler-sama...you actually came...", "hearts_anim", Message.SignalTiming.APPEAR, [], null, villain_portrait),
	Message.new("[VILLAIN]", "I...I have felt this way for s-so long...and...", "", Message.SignalTiming.NONE, [], null, villain_portrait),
	Message.new("[VILLAIN]", "I just had to tell you how I really feel!!", "", Message.SignalTiming.NONE, [], null, villain_portrait),
	Message.new("Tyler", "Wattup, saw ur note lol", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("[VILLAIN]", "After all we have been through...I wanted to ask you...", "", Message.SignalTiming.NONE, [], null, villain_portrait),
	Message.new("[VILLAIN]", "Do u love-love doki-doki me, Tyler-sempai?", "hearts_anim", Message.SignalTiming.APPEAR, [], null, villain_portrait),
	Message.new("Tyler", "...", "", Message.SignalTiming.NONE, [], tyler_portrait, null),
	Message.new("Tyler", "......", "", Message.SignalTiming.NONE, [], tyler_portrait, null),
	Message.new("Tyler", ".........", "", Message.SignalTiming.NONE, [], tyler_portrait, null),
	Message.new("Tyler", "**** no!", "cut_music", Message.SignalTiming.APPEAR, [], tyler_portrait, null),
	Message.new("[VILLAIN]", "...h-huh?", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("[VILLAIN]", "Th-this is impossible!", "", Message.SignalTiming.NONE, [], null, villain_portrait),
	Message.new("[VILLAIN]", "I thought I was THE ONE for you!!!", "", Message.SignalTiming.NONE, [], null, villain_portrait),
	Message.new("Tyler", "...there's someone else...", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("[VILLAIN]", "It's [WINNER], isn't it?!", "angry_anim", Message.SignalTiming.APPEAR, [], null, villain_portrait),
	Message.new("[VILLAIN]", "If I can't have you...", "", Message.SignalTiming.NONE, [], null, villain_portrait),
	Message.new("[VILLAIN]", "NO ONE CAN!!!", "start_battle_music", Message.SignalTiming.APPEAR, [], null, villain_portrait),
	Message.new("Tyler", "!!!NANI?!!!", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("[VILLAIN]", "Prepare to DIE!!", "final_battle", Message.SignalTiming.DISAPPEAR, [], null, villain_portrait),
]

func init():
	UI.money.visible = false
	camera.SetTarget(null)
	camera.transform.origin = Vector2(0, 0)
	get_parent().PauseWorld()
	get_parent().SetMessageQueue(messages, false)

func _ready():
	connect("final_battle", _startFinalBattle)
	connect("cut_music", _cutMusic)
	connect("start_battle_music", _startBattleMusic)
	connect("hearts_anim", _heartsAnim)
	connect("angry_anim", _angryAnim)
	connect("sparkle_anim", _sparkleAnim)
	Game.bgm_player.stream = confessionMusic
	Game.bgm_player.play()
	UI.background.texture = confessionBG
	UI.background.visible = true
	sakuraPetals.emitting = true
	
	for key in Game.users.keys():
		if key != Game.HOST_IP:
			if Game.winner_ip == "":
				Game.winner_ip = key
			elif Game.users[key].tyler_points > Game.users[Game.winner_ip].tyler_points:
				Game.winner_ip = key
	for message in messages:
		message.content = message.content.replace("[WINNER]", Game.users[Game.winner_ip].character_data.name)
	
	for key in Game.users.keys():
		if key != Game.HOST_IP:
			if Game.villain_ip == "":
				Game.villain_ip = key
			elif Game.users[key].tyler_points < Game.users[Game.villain_ip].tyler_points:
				Game.villain_ip = key
	villain_portrait = portraits[Game.users[Game.villain_ip].character_data.name]
	
	for message in messages:
		if message.speaker == "[VILLAIN]":
			message.speaker = Game.users[Game.villain_ip].character_data.name
			message.right_speaker = villain_portrait

func _startFinalBattle(args):
	UI.background.visible = false
	get_parent().StartBattle(["res://battle/Gatekeeper2.tres", "", true])

func _cutMusic(args):
	Game.bgm_player.stop()

func _heartsAnim(args):
	hearts.emitting = true

func _angryAnim(args):
	angry.emitting = true

func _sparkleAnim(args):
	sparkle.emitting = true

func _startBattleMusic(args):
	Game.bgm_player.stream = final_battle_music
	Game.bgm_player.play()

func _process(delta):
	pass
