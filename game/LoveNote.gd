extends TextureRect

@onready var cursor = $CheckMark
var cursor_position = 0
var max_option_position = 0

enum CursorPosition {LEFT, RIGHT}

func _ready():
	set_process(false)

func SetOptions(options):
	for i in range(0, $GridContainer.get_children().size(), 1):
		var label = $GridContainer.get_child(i)
		if i <= options.size() - 1:
			label.text = ""
			max_option_position = i
		else:
			label.text = ""
			
func MoveCursor(cursorPos):
	if cursorPos == CursorPosition.LEFT:
		cursor_position -= 1
		if cursor_position < 0:
			cursor_position = max_option_position
	elif cursorPos == CursorPosition.RIGHT:
		cursor_position += 1
		if cursor_position > max_option_position:
			cursor_position = 0
	cursor.position.x = 70 + ( 72 * cursor_position)
	
func SelectOption():
	print(cursor_position)
	return cursor_position
