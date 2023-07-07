extends Node2D

signal start_state
signal end_state
signal emote
signal sent_text
signal battle_entry

@onready var camera = $Camera2D
@onready var battle_info = $Camera2D/CanvasLayer/Control/BattleInfo
@onready var drop_box = $Camera2D/CanvasLayer/Control/DropBox
@onready var cursor = $Camera2D/CanvasLayer/Control/DropBox/Cursor

var moves = []
var cursor_position = 0
var turn = 0

func _ready():
	connect("start_state", _startState)
	connect("end_state", _endState)
	connect("emote", _emote)
	connect("sent_text", _sentText)
	connect("battle_entry", _battleEntry)
	
	camera.make_current()
	await get_tree().create_timer(0.8).timeout
	battle_info.Show("You've come to blows with a Gatekeeper!")
	await get_tree().create_timer(2.5).timeout
	battle_info.Hide()
	await get_tree().create_timer(0.8).timeout
	GetPartyMoves()
	
func _process(delta):
	if drop_box.visible:
		if Input.is_action_just_pressed("move_down"):
			cursor_position += 1
			if cursor_position > moves.size() - 1:
				cursor_position = 0
		elif Input.is_action_just_pressed("move_up"):
			cursor_position -= 1
			if cursor_position < 0:
				cursor_position = moves.size() - 1
		cursor.position.y = 10 + (19 * cursor_position)
		if Input.is_action_just_pressed("interact"):
			drop_box.visible = false
			battle_info.hide()
			await get_tree().create_timer(0.8).timeout
			battle_info.Show(moves[cursor_position])
			await get_tree().create_timer(2.0).timeout
			battle_info.Hide()
			await get_tree().create_timer(1.0)
			turn += 1
			if turn > 0:
				EndBattle()
			else:
				EnemyTurn()

func GetPartyMoves():
	moves.clear()
	battle_info.Show("The party is thinking about their next move...")
	var packet = {"action": "messageAllUsers"}
	var battle_prompt = Game.Prompt.new("Think of a powerful move that will help Tyler in battle!", "battle_entry", "countdown", 30.0, false, {"small": "Megaflare"})
	packet.merge(battle_prompt.data)
	Client.SendPacket(packet)
	
func EnemyTurn():
	battle_info.Show("The enemy attacks!")
	await get_tree().create_timer(2.0).timeout
	battle_info.Hide()
	await get_tree().create_timer(1.0)
	GetPartyMoves()
	
func _sentText(packet):
	emit_signal(packet["context"], packet)
	
func _emote(packet):
	pass

func _battleEntry(packet):
	moves.append(packet["smallInputValue"])
	var response = {"action": "respondToUser", "connectionID": packet["connectionID"]}
	var wait_prompt = Game.Prompt.new("Please wait...", "wait", "none", 0.0, false, {"big": ""})
	response.merge(wait_prompt.data)
	Client.SendPacket(response)
	
	if moves.size() == Game.users.size() - 1:
		battle_info.SetText(true, "Choose the best one, Tyler!")
		for option in drop_box.get_child(0).get_children():
			option.text = ""
		for i in range(0, moves.size(), 1):
			drop_box.get_child(0).get_child(i).text = moves[i]
		drop_box.visible = true
		
func EndBattle():
	battle_info.Show("Tyler and company are victorious!")
	await get_tree().create_timer(3.0).timeout
	battle_info.Hide()
	Transition.get_node("AnimationPlayer").play("fade_out")
	await get_tree().create_timer(0.4).timeout
	Game.ChangeState(self, Game.previous_state)
	Transition.get_node("AnimationPlayer").play("fade_in")

func _startState():
	pass

func _endState():
	queue_free()
	get_parent().remove_child(self)
