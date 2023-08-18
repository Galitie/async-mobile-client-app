extends Map

signal final_battle

var teacher_portrait = load("res://school/portraits/teacher.png")
var tyler_portrait = load("res://school/portraits/tyler.png")
var mario_portrait = load("res://school/portraits/mario.png")
var kermit_portrait = load("res://school/portraits/kermit.png")
var snake_portrait = load("res://school/portraits/snake.png")
var shadow_portrait = load("res://school/portraits/shadow.png")
var shrek_portrait = load("res://school/portraits/shrek.png")

var confessionBG = load("res://school/Outside_sakura_tree.png")
var confessionMusic = load("res://school/confessionMusic.mp3")
@onready var sakuraPetals = $CanvasLayer/SakuraPetals
@onready var camera = get_parent().get_node("Camera2D")

# placeholder
var villain_portrait = snake_portrait

var messages = [
	Message.new("Tyler", "Ok...I'm finally in the courtyard...", "", Message.SignalTiming.NONE, [], tyler_portrait, null),
	Message.new("Tyler", "It was so hard telling all those other people that I'm not interested in them!", "", Message.SignalTiming.NONE, [], tyler_portrait, null),
	Message.new("Tyler", "They all took it really well, sugoi!!", "", Message.SignalTiming.NONE, [], tyler_portrait, null),
	Message.new("Tyler", "Now it's time to talk to the final person...", "", Message.SignalTiming.NONE, [], tyler_portrait, null),
	Message.new("Tyler", "I bet this will go really well!!!!", "", Message.SignalTiming.NONE, [], tyler_portrait, null),
	Message.new("Secret Admirer", "T-Tyler-sama...you came...", "", Message.SignalTiming.NONE, [], null, villain_portrait),
	Message.new("Secret Admirer", "I...I have felt this way for so long...", "", Message.SignalTiming.NONE, [], null, villain_portrait),
	Message.new("Tyler", "Hey wattup, I saw ur note", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("Secret Admirer", "Do u love me Tyler-sama?", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("Tyler", "...", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("Tyler", "......", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("Tyler", ".........", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("Tyler", "no.", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("Secret Admirer", "...h-huh?", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("Secret Admirer", "b-but...Tyler-sama said no to everyone else...I thought...", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("Secret Admirer", "I thought I was the one for you?!", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("VILLIAN", "If I can't have you, NO ONE CAN!", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
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
	Game.bgm_player.stream = confessionMusic
	Game.bgm_player.play()
	UI.background.texture = confessionBG
	UI.background.visible = true
	sakuraPetals.emitting = true

func _startFinalBattle(args):
	UI.background.visible = false
	get_parent().StartBattle(["res://battle/Gatekeeper2.tres"])

func _process(delta):
	pass
