extends Node2D

@onready var client = get_parent()
@onready var camera = $Camera2D
@onready var battle_info = $Camera2D/CanvasLayer/Control/BattleInfo
@onready var drop_box = $Camera2D/CanvasLayer/Control/DropBox

var moves = []

func _ready():
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
	var battle_prompt = Global.Prompt.new("Think of a powerful move that will help Tyler in battle!", "battleEntry", "countdown", 30.0, false, {"small": "Megaflare"})
	packet.merge(battle_prompt.data)
	client.SendPacket(packet)
	
func ParseContext(packet):
	BattleEntry(packet)

func BattleEntry(packet):
	moves.append(packet["smallInputValue"])
	var response = {"action": "respondToUser", "connectionID": packet["connectionID"]}
	var wait_prompt = Global.Prompt.new("Please wait...", "wait", "none", 0.0, false, {"big": ""})
	response.merge(wait_prompt.data)
	client.SendPacket(response)
	
	if moves.size() == 1:
		battle_info.SetText(true, "Choose the best one, Tyler!")
		drop_box.visible = true
