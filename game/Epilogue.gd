extends Control

var villain_ep = [
	"At 3:52 PM JST, [VILLAIN] succumbed to their injuries at Kawaii Hospital, Tokyo.",
	"Apparently, dropping a comet on yourself does that."
]

var tyler_ep = [
	"Without much deliberation, Tyler eloped with [WINNER].",
	"The two plan to spend the rest of their days in a cabin along Japanese waters.",
	"[center]The End"
]

var snake_ep = [
	"Snake blamed the entire incident on the Patriots.",
	"He was last seen trekking through Alaska.",
	"[center]\"...Alaska?\""
]

var mario_ep = [
	"\"Super Mario: Underage High School Brawl-out\" becomes a smash hit.",
	"Shigeru Miyamoto resigns due to immediate, unforseen controversy."
]

var shrek_ep = [
	"[center]As for Shrek, somebody once told him...",
	"[center]The world was gonna roll him.",
	"[center]He ain't the sharpest tool in the shed."
]

var shadow_ep = [
	"Shadow continues on his quest to find out who he is.",
	"[center]...Whatever that means."
]

var kermit_ep = [
	"Kermit kills Ms. Piggy and marries Animal or something.",
	"[center]I don't know or care about the Muppets.",
	"[center]Sorry."
]

@onready var label = $Background/Label
var dialogues = []
var dialogue = 0
var line = 0
var finished = false
var next_epilogue = false

var reading_time = 3.0

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
			await get_tree().create_timer(2.0).timeout
			
		label.text = dialogues[dialogue][line]
		await get_tree().create_timer(0.2).timeout
		label.visible = true
		await get_tree().create_timer(reading_time).timeout
		progress()

func _ready():
	label.visible = false
	dialogues = [villain_ep, snake_ep, mario_ep, shrek_ep, shadow_ep, kermit_ep, tyler_ep]
	
func start(supernova_music):
	var bgm_tween = get_tree().create_tween()
	bgm_tween.tween_property(supernova_music, "volume_db", -200, 24)
	
	label.text = dialogues[0][0]
	label.visible = true
	await get_tree().create_timer(reading_time).timeout
	progress()
