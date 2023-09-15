class_name Battle
extends Node2D

signal start_state
signal end_state
signal sent_text
signal battle_entry
signal user_joined
signal user_disconnected
signal speak

@onready var camera = $Camera2D
@onready var battle_info = $Camera2D/CanvasLayer/Control/BattleInfo
@onready var enemy = $Enemy
@onready var move_effects = $MoveEffects
@onready var enemy_move_effects = $MoveEffects2

var music
var victory_music = load("res://battle/victory.mp3")
var final_battle = false

class Move:
	var ip
	var content
	
	func _init(_ip, _content):
		ip = _ip
		content = _content

var moves = []
var cursor_position = 0
var turn = 0
var max_turns = 3
var enemy_health = 3

var enemy_info = null
var party_turn = false
var battle_over = false

@onready var villain_prompt = Game.Prompt.new("NON-STOP SHIT TALK THE MAN WHO BROKE YOUR HEART.", "speak", "none", 0.0, true, {"big": "Fuck you Tyler!"})
@onready var supernova = $Supernova

func _ready():
	if final_battle:
		$Background.visible = true
		$DirectionalLight2D.visible = false
		$PointLight2D.visible = false
		$AnimationPlayer.animation_finished.connect(_startEpilogue)
		$EnemyHealthBar.visible = true
		
		var villain_sprite = $Party.get_node(Game.users[Game.villain_ip].character_data.name)
		villain_sprite.visible = false
		enemy.texture = villain_sprite.texture
		set_enemy_health_bar()
		enemy.flip_h = true
		Game.SendPromptToUser(villain_prompt, Game.villain_ip)
		var supernova_scene = load("res://battle/finalBattle/Supernova.tscn")
		var supernova_instance = supernova_scene.instantiate()
		supernova.add_child(supernova_instance)
		supernova.visible = false
	else:
		$EnemyHealthBar.visible = true
		$Background.visible = false
		Game.bgm_player.stream = music
		Game.bgm_player.play()
		enemy.texture = enemy_info.texture
		set_enemy_health_bar()
		
	UI.money.visible = false
	
	connect("start_state", _startState)
	connect("end_state", _endState)
	connect("sent_text", _sentText)
	connect("battle_entry", _battleEntry)
	connect("user_disconnected", _userDisconnected)
	connect("user_joined", _userJoined)
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
	
	if UI.drop_box.visible:
		if Input.is_action_just_pressed("move_down"):
			$CursorSound.play()
			UI.drop_box.MoveCursor(UI.drop_box.CursorPosition.DOWN)
		elif Input.is_action_just_pressed("move_up"):
			$CursorSound.play()
			UI.drop_box.MoveCursor(UI.drop_box.CursorPosition.UP)
		if Input.is_action_just_pressed("interact"):
			$SelectedSound.play()
			var move = moves[UI.drop_box.SelectOption()]
			Game.users[move.ip].tyler_points += 1
			UI.drop_box.visible = false
			battle_info.hide()
			await get_tree().create_timer(0.8).timeout
			battle_info.Show(Game.users[move.ip].character_data.name + " used " + move.content + "!!!", "", null, true)
			await get_tree().create_timer(2.0).timeout
			var move_effect = move_effects.get_children().pick_random()
			var moveSound = move_effect.get_child(0, true)
			moveSound.play()
			move_effect.emitting = true
			$Enemy/AnimationPlayer.play("onhit")
			get_node("RandomDamage").playAnimation()
			update_enemy_health_bar()
			battle_info.Hide()
			await get_tree().create_timer(1.5).timeout
			turn += 1
			if turn >= max_turns:
				EndBattle(delta)
			else:
				EnemyTurn()
	elif battle_over:
		if Input.is_action_just_pressed("interact"):
			$SelectedSound.play()
			UI.transition.get_node("AnimationPlayer").play("fade_out")
			await get_tree().create_timer(0.4).timeout
			Game.ChangeState(self, Game.previous_state)
			UI.transition.get_node("AnimationPlayer").play("fade_in")

func set_enemy_health_bar():
	$EnemyHealthBar.value = max_turns

func update_enemy_health_bar():
	$EnemyHealthBar.value = $EnemyHealthBar.value - 1
	
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
			await get_tree().create_timer(2.0).timeout
			var bgm_tween = get_tree().create_tween()
			bgm_tween.tween_property(Game.bgm_player, "volume_db", -200, 24)
			battle_info.Show(Game.users[Game.villain_ip].character_data.name + ": \"Enough! Time to end this! Super Nova!!!\"", "", null, true)
			$EnemyHealthBar.visible = false
			await get_tree().create_timer(2.0).timeout
			get_node("AnimationPlayer").play("supernova")
			supernova.visible = true
			supernova.get_child(0).play()
			await get_tree().create_timer(3.0).timeout
			battle_info.Hide()
		else:
			battle_info.Show(Game.users[Game.villain_ip].character_data.name + " lashes out!", "", null, true)
			await get_tree().create_timer(2.0).timeout
			var move_effect = enemy_move_effects.get_children().pick_random()
			var moveSound = move_effect.get_child(0, true)
			moveSound.play()
			move_effect.emitting = true
			await get_tree().create_timer(1.0).timeout
			get_node("RandomDamage2").playAnimation()
			await get_tree().create_timer(2.0).timeout
			battle_info.Hide()
			PartyTurn()
	else:
		battle_info.Show("The " + enemy_info.enemy_name + " attacks!", "", null, true)
		await get_tree().create_timer(2.0).timeout
		var move_effect = enemy_move_effects.get_children().pick_random()
		var moveSound = move_effect.get_child(0, true)
		moveSound.play()
		move_effect.emitting = true
		await get_tree().create_timer(1.0).timeout
		get_node("RandomDamage2").playAnimation()
		await get_tree().create_timer(2.0).timeout
		battle_info.Hide()
		PartyTurn()
	
func _sentText(packet):
	emit_signal(packet["context"], packet)
	
func _userJoined(packet):
	# Reconnect on login if name matches
	var user_name = packet["smallInputValue"].to_lower()
	packet["userIP"] = user_name
	if Game.users.has(user_name):
		if Game.users[user_name].connection_status == Client.CONNECTION_STATUS.OFFLINE:
			Game.users[user_name].connection_status = Client.CONNECTION_STATUS.ONLINE
			Game.users[user_name].connection_id = packet["connectionID"]
			Client.SendPacket({"action": "updateUser", "role": "user", "userIP": user_name, "connectionID": packet["connectionID"]})
			await Client.userUpdated
			if user_name == Game.villain_ip && turn < max_turns - 1:
				Game.SendPromptToUser(villain_prompt, user_name)
			else:
				Game.SendPromptToUser(Game.wait_prompt, user_name)
		else:
			var response = {"action": "respondToUser", "message": "refuseJoin", "connectionID": packet["connectionID"]}
			Client.SendPacket(response)
	else:
		var response = {"action": "respondToUser", "message": "refuseJoin", "connectionID": packet["connectionID"]}
		Client.SendPacket(response)
	
func _userDisconnected(packet):
	if party_turn && packet["userIP"] != Game.villain_ip:
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
		UI.drop_box.SetOptions(moves)
		$TylerNotif.play()
		UI.drop_box.visible = true
		party_turn = false
		
func EndBattle(delta):
	enemy.get_node("AnimationPlayer").play("dead")
	$EnemyHealthBar.visible = false
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
	UI.money.visible = true
	queue_free()
	get_parent().remove_child(self)
	
func _speak(packet):
	UI.left_speaker.texture = null
	UI.right_speaker.texture = null
	UI.message_box.Show(packet["bigInputValue"], Game.users[packet["userIP"]].character_data.name, Game.users[packet["userIP"]].character_data.icon_region, true)
	DisplayServer.tts_speak(packet["bigInputValue"], Game.users[packet["userIP"]].voice_id, 50, Game.users[packet["userIP"]].character_data.voice_pitch)

func _startEpilogue(anim):
	var supernova_bgm = supernova.get_child(0).get_node("AudioStreamPlayer2D")
	UI.epilogue.visible = true
	UI.epilogue.start(supernova_bgm)
