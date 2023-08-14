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

var villain_portrait = snake_portrait

var messages = [
	Message.new("VILLIAN", "T-Tyler-sama...", "", Message.SignalTiming.NONE, [], null, villain_portrait),
	Message.new("test", "Hey wattup", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("VILLIAN", "Do u love me", "", Message.SignalTiming.NONE, [], tyler_portrait, villain_portrait),
	Message.new("test", "Nope", "final_battle", Message.SignalTiming.DISAPPEAR, [], tyler_portrait, villain_portrait),
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
