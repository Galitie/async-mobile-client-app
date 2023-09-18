extends Control

var epilogues = {
	"Villain" : [
	"At 3:52 PM JST, [VILLAIN] succumbed to their injuries at Kawaii Hospital, Tokyo.",
	"Apparently, missing your attack and dropping a comet on yourself does that.",
	"There must have been an error in their space calculations..."
],
	"Mario" : [
	"Mario is still looking for a princess to share his plumber dreams with.",
	"Some say he's still looking to this day.",
	"She's probably in some other castle..."
],
	"Snake" : [
	"Snake blamed the entire incident on the Patriots.",
	"He was last seen trekking through Alaska with his team of doggos.",
	"[center]\"...Alaska? Metal...gear...?\""
],
	"Shadow" : [
	"Shadow continues on his quest to find out who he is.",
	"[center]...Whatever that means."
],
	"Kermit" : [
	"Kermit kills Ms. Piggy and marries Animal or something.",
	"[center]I don't know or care about the Muppets.",
	"[center]Sorry."
],
	"Shrek" : [
	"[center]As for Shrek, somebody once told him...",
	"[center]The world was gonna roll him.",
	"[center]He ain't the sharpest tool in the shed."
],
	"End" : [
	"Without much deliberation, Tyler eloped with [WINNER].",
	"The two plan to happily spend the rest of their days in a cozy cabin along the coast.",
	"[center]The End...",
	"[center]Happy Birthday Tyler! <3, Galit & Raam"
]
}

@onready var label = $Background/Label
var dialogues = []
var dialogue = 0
var line = 0
var finished = false
var next_epilogue = false

var reading_time = 4.0

func progress():
	line += 1
	if line > dialogues[dialogue].size() - 1:
		line = 0
		dialogue += 1
		next_epilogue = true
		if dialogue > dialogues.size() - 1:
			finished = true
	
	if !finished:
		label.visible = false
		
		if next_epilogue:
			next_epilogue = false
			await get_tree().create_timer(3.0).timeout
			
		label.text = dialogues[dialogue][line]
		await get_tree().create_timer(0.2).timeout
		label.visible = true
		await get_tree().create_timer(reading_time).timeout
		progress()

func _ready():
	label.visible = false
	dialogues = [epilogues["Villain"], epilogues["Snake"], epilogues["Mario"], epilogues["Shrek"], epilogues["Shadow"], epilogues["Kermit"], epilogues["End"]]
	
func start(supernova_music):
	var villain_name = Game.users[Game.villain_ip].character_data.name
	dialogues[0][0] = dialogues[0][0].replace("[VILLAIN]", villain_name)
	for key in epilogues.keys():
		if villain_name == key:
			dialogues.erase(epilogues[villain_name])
			
	var winner_name = Game.users[Game.winner_ip].character_data.name
	dialogues[dialogues.size() - 1][0] = dialogues[dialogues.size() - 1][0].replace("[WINNER]", winner_name)
	for key in epilogues.keys():
		if winner_name == key:
			dialogues.erase(epilogues[winner_name])
	
	var bgm_tween = get_tree().create_tween()
	bgm_tween.tween_property(supernova_music, "volume_db", -200, 24)
	$AnimationPlayer.play("fade_in")
	await get_tree().create_timer(4.0).timeout
	label.text = dialogues[0][0]
	label.visible = true
	await get_tree().create_timer(reading_time).timeout
	progress()
