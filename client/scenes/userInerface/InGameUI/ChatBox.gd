extends Panel
onready var label = $VBoxContainer/HBoxContainer/Label
onready var line_edit = $VBoxContainer/HBoxContainer/LineEdit
onready var chat_log = $VBoxContainer/RichTextLabel
onready var focus_bool = false
onready var timer = $Timer

var groups: Array = [
	{"name": "all", "color": "#ffffff"},
	{"name": "friends", "color": "#fffb00"},
	{"name": "party", "color": "#00fff9"},
	{"name": "guild", "color": "#ff002a"},
	#{"name": "whisper", "color": "#02f900"},
]

var group_index: int = 0
var user_name: String

func _ready():
	change_group(0)

func _input(event) -> void:
	if Global.in_game:
		if event is InputEventKey:
			if event.pressed and event.scancode == KEY_ENTER:
				if line_edit.get_focus_owner() == line_edit:
					if line_edit.text.length() > 0:
						print("send server entered text")
						line_edit.text = ""
					else:
						print("line edit will unfocus")
						line_edit.release_focus()
				else:
					print("lineedit will be focused")
					line_edit.grab_focus()
			elif event.pressed and event.scancode == KEY_ESCAPE:
				if line_edit.get_focus_owner() == line_edit:
					print("escape pressed lineedit unfocused")
					line_edit.release_focus()
				else:
					print("escape pressed but chat not focused")
			elif event.pressed and event.scancode == KEY_TAB and line_edit.get_focus_owner() == line_edit:
				change_group(1)
			
func change_group(value: int) -> void:
	group_index += value
	if group_index > (groups.size()-1):
		group_index = 0
	label.text = groups[group_index]["name"]
	label.set("custom_colors/font_color", Color(groups[group_index]["color"]))
	

func update_message(username:String, text: String,  group:int = 0) -> void:
	chat_log.bbcode_text += "\n"
	chat_log.bbcode_text += "[color=" + groups[group]["color"] + "]"
	chat_log.bbcode_text += "[" + username + "]: "
	chat_log.bbcode_text += text
	chat_log.bbcode_text += "[/color]"

func send_message(text: String, group: int = 0) -> void:
	pass
