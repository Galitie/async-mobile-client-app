extends Node2D

signal emote
signal sent_text
signal battle_entry

@onready var camera = $Camera2D
@onready var battle_info = $Camera2D/CanvasLayer/Control/BattleInfo
@onready var drop_box = $Camera2D/CanvasLayer/Control/DropBox

var moves = []

func _ready():
	connect("emote", _emote)
	connect("sent_text", _sentText)
	connect("battle_entry", _battleEntry)
	
	camera.make_current()
	await get_tree().create_timer(0.8).timeout
	battle_info.Show("You've come to blows with a [color=yellow]Gatekeeper!")
	await get_tree().create_timer(2.5).timeout
	battle_info.Hide()
	await get_tree().create_timer(0.8).timeout
	GetPartyMoves()
	
func _process(delta):
	if drop_box.visible:
		pass

func GetPartyMoves():
	battle_info.Show("The party is thinking about their next move...")
	var packet = {"action": "messageAllUsers"}
	var battle_prompt = Game.Prompt.new("Think of a powerful move that will help Tyler in battle!", "battle_entry", "countdown", 30.0, false, {"small": "Megaflare"})
	packet.merge(battle_prompt.data)
	Client.SendPacket(packet)
	
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
		drop_box.visible = true
