extends TextureRect

@onready var cursor = $Cursor
var cursor_position = 0
var max_option_position = 0

enum CursorPosition {UP, DOWN}

func _ready():
	set_process(false)

func SetOptions(options):
	for i in range(0, $GridContainer.get_children().size(), 1):
		var label = $GridContainer.get_child(i)
		if i <= options.size() - 1:
			label.text = options[i].content
			max_option_position = i
		else:
			label.text = ""
			
func MoveCursor(cursorPos):
	if cursorPos == CursorPosition.UP:
		cursor_position -= 1
		if cursor_position < 0:
			cursor_position = max_option_position
	elif cursorPos == CursorPosition.DOWN:
		cursor_position += 1
		if cursor_position > max_option_position:
			cursor_position = 0
	cursor.position.y = 9 + (19 * cursor_position)
	
func SelectOption():
	var current_position = cursor_position
	cursor_position = 0
	return current_position
