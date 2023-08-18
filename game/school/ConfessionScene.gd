extends Map

signal final_battle
signal start_battle_music
signal cut_music

var teacher_portrait = load("res://school/portraits/teacher.png")
var tyler_portrait = load("res://school/portraits/tyler.png")
var mario_portrait = load("res://school/portraits/mario.png")
var kermit_portrait = load("res://school/portraits/kermit.png")
var snake_portrait = load("res://school/portraits/snake.png")
var shadow_portrait = load("res://school/portraits/shadow.png")
var shrek_portrait = load("res://school/portraits/shrek.png")

var confessionBG = load("res://school/Outside_sakura_tree.png")
var confessionMusic = load("res://school/confessionMusic.mp3")
var final_battle_music = load("res://battle/finalBattle/final_battle.mp3")
@onready var sakuraPetals = $CanvasLayer/SakuraPetals
@onready var camera = get_parent().get_node("Camera2D")

# placeholder
var villain_portrait = snake_portrait

var messages = [
	Message.new("Tyler", "Ok...I'm finally in the courtyard...", "", Message.SignalTiming.NONE, [], tyler_portrait, null),
	Message.new("Tyler", "I'm so nervous, sugoi!!", "", Message.SignalTiming.NONE, [], tyler_portrait, null),
	Message.new("Tyler", "Now it's time to talk to *this* person...", "", Message.SignalTiming.NONE, [], tyler_portrait, null),
	Message.new("Tyler", "I bet this will go really well!!!!", "", Message.SignalTiming.NONE, [], tyler_portrait, null),
	Message.new("VILLIAN", "T-Tyler-sama...you came...", "", Message.SignalTiming.NONE, [], null, villain_portrait),
	Message.new("VILLIAN", "I...I have felt this way for so long...", "", Message.SignalTiming.NONE, [], null, villain_portrait),
	Message.new("Tyler", "Wattup, saw ur note.", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("VILLIAN", "Do u love me Tyler-sama?", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("Tyler", "...", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("Tyler", "......", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("Tyler", ".........", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("Tyler", "Fuck no!", "cut_music", Message.SignalTiming.APPEAR, [], tyler_portrait, villain_portrait),
	Message.new("VILLIAN", "...h-huh?", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("VILLIAN", "I thought I was the one for you?!", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("VILLIAN", "If I can't have you, NO ONE CAN!", "start_battle_music", Message.SignalTiming.APPEAR, [], tyler_portrait, villain_portrait),
	Message.new("Tyler", "!!!NANI?!!!", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("VILLIAN", "Prepare to DIE!!", "final_battle", Message.SignalTiming.DISAPPEAR, [], tyler_portrait, villain_portrait),
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
	Game.bgm_player.stream = confessionMusic
	Game.bgm_player.play()
	UI.background.texture = confessionBG
	UI.background.visible = true
	sakuraPetals.emitting = true

func _startFinalBattle(args):
	UI.background.visible = false
	get_parent().StartBattle(["res://battle/Gatekeeper2.tres", "", true])

func _cutMusic(args):
	Game.bgm_player.stop()
	
func _startBattleMusic(args):
	Game.bgm_player.stream = final_battle_music
	Game.bgm_player.play()

func _process(delta):
	pass
