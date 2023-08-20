class_name Battle
extends Node2D

signal start_state
signal end_state
signal sent_text
signal battle_entry
signal user_reconnected
signal user_disconnected
signal speak

@onready var camera = $Camera2D
@onready var battle_info = $Camera2D/CanvasLayer/Control/BattleInfo
@onready var drop_box = $Camera2D/CanvasLayer/Control/DropBox
@onready var cursor = $Camera2D/CanvasLayer/Control/DropBox/Cursor
@onready var enemy = $Enemy
@onready var move_effects = $MoveEffects

var music
var victory_music = load("res://battle/victory.mp3")
var final_battle = false

class Move:
	var ip
	var name
	
	func _init(_ip, _name):
		ip = _ip
		name = _name

var moves = []
var cursor_position = 0
var turn = 0
var max_turns = Game.users.size() - 1

var enemy_info = null
var party_turn = false
var battle_over = false

@onready var villain_prompt = Game.Prompt.new("SHIT TALK THE MAN WHO BROKE YOUR HEART.", "speak", "none", 0.0, true, {"big": "Fuck you Tyler!"})
@onready var supernova = $Supernova

func _ready():
	if final_battle:
		$Background.visible = true
		$DirectionalLight2D.visible = false
		$PointLight2D.visible = false
		$AnimationPlayer.animation_finished.connect(_startEpilogue)
		
		var villain_sprite = $Party.get_node(Game.users[Game.villain_ip].character_data.name)
		villain_sprite.visible = false
		enemy.texture = villain_sprite.texture
		enemy.flip_h = true
		Game.SendPromptToUser(villain_prompt, Game.villain_ip)
		var supernova_scene = load("res://battle/finalBattle/Supernova.tscn")
		var supernova_instance = supernova_scene.instantiate()
		supernova.add_child(supernova_instance)
		supernova.visible = false
	else:
		$Background.visible = false
		Game.bgm_player.stream = music
		Game.bgm_player.play()
		enemy.texture = enemy_info.texture
		
	UI.money.visible = false
	
	connect("start_state", _startState)
	connect("end_state", _endState)
	connect("sent_text", _sentText)
	connect("battle_entry", _battleEntry)
	connect("user_disconnected", _userDisconnected)
	connect("user_reconnected", _userReconnected)
	connect("speak", _speak)
	
	camera.make_current()
	await get_tree().create_timer(0.8).timeout
	if final_battle:
		battle_info.Show(Game.users[Game.villain_ip].character_data.name + " is heartbroken!", "", null, true)
	else:
		battle_info.Show("It's a " + enemy_info.enemy_name + "!", "", null, true)
	await get_tree().create_timer(2.5).timeout
	battle_info.Hide()
	await get_tree().create_timer(0.8).timeout
	PartyTurn()
	
func _process(delta):
	if !DisplayServer.tts_is_speaking():
		UI.message_box.Hide()
	
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
			var move = moves[cursor_position]
			Game.users[move.ip].tyler_points += 1
			drop_box.visible = false
			battle_info.hide()
			await get_tree().create_timer(0.8).timeout
			battle_info.Show("Tyler used " + move.name + "!!!", "", null, true)
			await get_tree().create_timer(2.0).timeout
			var move_effect = move_effects.get_children().pick_random()
			var moveSound = move_effect.get_child(0, true)
			moveSound.play()
			move_effect.emitting = true
			$Enemy/AnimationPlayer.play("onhit")
			get_node("RandomDamage").playAnimation()
			battle_info.Hide()
			await get_tree().create_timer(1.5).timeout
			turn += 1
			if turn >= max_turns:
				EndBattle(delta)
			else:
				EnemyTurn()
	elif battle_over:
		if Input.is_action_just_pressed("interact"):
			UI.transition.get_node("AnimationPlayer").play("fade_out")
			await get_tree().create_timer(0.4).timeout
			Game.ChangeState(self, Game.previous_state)
			UI.transition.get_node("AnimationPlayer").play("fade_in")

func PartyTurn():
	party_turn = true
	moves.clear()
	battle_info.Show("The party is thinking about their next move...", "", null, true)
	var battle_prompt = Game.Prompt.new("Think of a powerful move that will help Tyler in battle!", "battle_entry", "countdown", 30.0, false, {"small": "Megaflare"})
	Game.SendPromptToUsers(battle_prompt)
	
func EnemyTurn():
	if final_battle:
		if turn == max_turns - 1:
			Game.SendPromptToUsers(Game.wait_prompt, false, false)
			get_tree().root.get_node("/root/World/ConfessionScene/CanvasLayer/SakuraPetals").emitting = false
			var bgm_tween = get_tree().create_tween()
			bgm_tween.tween_property(Game.bgm_player, "volume_db", -200, 24)
			battle_info.Show(Game.users[Game.villain_ip].character_data.name + ": \"Enough! Super Nova!\"", "", null, true)
			get_node("AnimationPlayer").play("supernova")
			supernova.visible = true
			supernova.get_child(0).play()
			await get_tree().create_timer(3.0).timeout
			battle_info.Hide()
		else:
			battle_info.Show(Game.users[Game.villain_ip].character_data.name + " lashes out!", "", null, true)
			await get_tree().create_timer(2.0).timeout
			battle_info.Hide()
			await get_tree().create_timer(1.0)
			PartyTurn()
	else:
		battle_info.Show("The " + enemy_info.enemy_name + " attacks!", "", null, true)
		await get_tree().create_timer(2.0).timeout
		battle_info.Hide()
		await get_tree().create_timer(1.0)
		PartyTurn()
	
func _sentText(packet):
	emit_signal(packet["context"], packet)
	
func _userReconnected(packet):
	Game.SendPromptToUser(Game.wait_prompt, packet["userIP"])
	
func _userDisconnected(packet):
	if party_turn:
		for move in moves:
			if move.ip == packet["userIP"]:
				return
		moves.append(Move.new(packet["userIP"], "*blushes*"))
		CheckAllMovesSubmitted()

func _battleEntry(packet):
	moves.append(Move.new(packet["userIP"], packet["smallInputValue"]))
	Game.SendPromptToUser(Game.wait_prompt, packet["userIP"])
	CheckAllMovesSubmitted()
		
func CheckAllMovesSubmitted():
	var max_submissions = Game.users.size() - 1
	if final_battle:
		max_submissions -= 1
	if moves.size() == max_submissions:
		battle_info.SetText(true, "Choose your favorite attack, Tyler!")
		for option in drop_box.get_child(0).get_children():
			option.text = ""
		for i in range(0, moves.size(), 1):
			drop_box.get_child(0).get_child(i).text = moves[i].name
		drop_box.visible = true
		party_turn = false
		
func EndBattle(delta):
	enemy.get_node("AnimationPlayer").play("dead")
	await get_tree().create_timer(1.4).timeout
	Game.bgm_player.stop()
	var final_blow_user = Game.users[moves[cursor_position].ip]
	DisplayServer.tts_speak(final_blow_user.catchphrase, final_blow_user.voice_id, 50.0, final_blow_user.character_data.voice_pitch)
	UI.message_box.Show(final_blow_user.catchphrase, final_blow_user.character_data.name, final_blow_user.character_data.icon_region, true)
	await get_tree().create_timer(3.0).timeout
	UI.message_box.Hide()
	Game.bgm_player.stream = victory_music
	Game.bgm_player.play()
	battle_info.Show("Tyler and company are victorious!")
	battle_over = true
	
func _startState():
	pass

func _endState():
	queue_free()
	get_parent().remove_child(self)
	
func _speak(packet):
	UI.message_box.Show(packet["bigInputValue"], Game.users[packet["userIP"]].character_data.name, Game.users[packet["userIP"]].character_data.icon_region, true)
	DisplayServer.tts_speak(packet["bigInputValue"], Game.users[packet["userIP"]].voice_id, 50, Game.users[packet["userIP"]].character_data.voice_pitch)

func _startEpilogue(anim):
	var supernova_bgm = supernova.get_child(0).get_node("AudioStreamPlayer2D")
	UI.epilogue.visible = true
	UI.epilogue.start(supernova_bgm)
