extends HBoxContainer

onready var label = $Label
onready var line_edit = $LineEdit
onready var group_index: int = 0

var groups: Array = [
	{"name": "all", "color": "#ffffff"},
	{"name": "friends", "color": "#fffb00"},
	{"name": "party", "color": "#00fff9"},
	{"name": "guild", "color": "#ff002a"},
	#{"name": "whisper", "color": "#02f900"},
]

func _ready():
	InputManager.line_edit = $LineEdit
	Signals.connect("toggle_chat_group", self, "toggle_chat_group")
# warning-ignore:return_value_discarded
	Signals.connect("send_message", self, "send_message")

func change_group(value: int) -> void:
	group_index += value
	if group_index > (groups.size()-1):
		group_index = 0
	label.text = groups[group_index]["name"]
	label.set("custom_colors/font_color", Color(groups[group_index]["color"]))

func send_message() -> void:
	#print(line_edit.text, " ", group_index)
	Server.send_chat(line_edit.text, group_index)
	line_edit.text = ""
