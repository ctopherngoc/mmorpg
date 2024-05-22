extends Panel
onready var label = $VBoxContainer/HBoxContainer/Label
onready var line_edit = $VBoxContainer/HBoxContainer/LineEdit
onready var chat_log = $VBoxContainer/RichTextLabel
onready var focus_bool = false

var origin: Vector2 = Vector2(0,586)

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
	#origin = self.rect_position
	InputManager.line_edit = $VBoxContainer/HBoxContainer/LineEdit
# warning-ignore:return_value_discarded
	Signals.connect("toggle_chat_group", self, "toggle_chat_group")
# warning-ignore:return_value_discarded
	Signals.connect("send_message", self, "send_message")
	change_group(0)
			
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

func send_message() -> void:
	#print(line_edit.text, " ", group_index)
	Server.send_chat(line_edit.text, group_index)
	line_edit.text = ""
	
func toggle_chat_group() -> void:
	change_group(1)

func _input(event) -> void:
	if event is InputEventMouseButton:
		pass
		#print(get_global_mouse_position())
		
		# as y decraeases (mouse goes higher) window size should go up in y and position should go down for y
# warning-ignore:unused_argument
func mouse_drag_management(event: InputEvent) -> void:
	if Input.is_action_pressed("click"):

		#print(self.rect_position.y, " ", get_global_mouse_position().y, " ", self.rect_size.y, " ", self.rect_min_size.y)
		var difference = self.rect_position.y - get_global_mouse_position().y
		if self.rect_size.y > self.rect_min_size.y:
			if get_global_mouse_position().y > 0:
				self.rect_size.y += difference
				self.rect_position.y = get_global_mouse_position().y
			else:
				pass
		else:
			if difference > 0:
				self.rect_size.y += difference
				self.rect_position.y = get_global_mouse_position().y
				
			else:
				self.rect_position = origin
		#self.rect_position.y = get_global_mouse_position().y
		#resize_area.rect_position = panel.rect_size - resize_area.rect_min_size / 2

func _on_Control_gui_input(event):
	mouse_drag_management(event)
