extends Node

var line_edit: LineEdit
var options_toggled = false

var keybind_dict = {"Shift": 'shift', "Insert": 'ins', "Home": 'home',"PageUp": 'pgup',"Control": 'ctrl', "Delete": 'del',"End": 'end',"PageDown": 'pgdn',
	"QuoteLeft": '`', "1": '1', "2": '2', "3": '3', "4": '4', "5": '5', "7": '7', "8": '8', "9": '9', "0": '0', "Minus": '-', "Equal": '=',
	 "F1": 'f1', "F2": 'f2', "F3": 'f3', "F4": 'f4', "F5": 'f5', "F6": 'f6', "F7": 'f7', "F8": 'f8', "F9": 'f9', "F0": 'f10', "F11": 'f11', "F12": 'f12',
	"Q": 'q', "W": 'w', "E": 'e', "R": 'r', "T": 't', "Y": 'y', "U": 'u', "I": 'i', "O": "o", "P": 'p', "BracketLeft": '[', "BracketRight": ']',
	"A": 'a', "S": 's', "D": 'd', "F": 'f', "G": 'g', "H": 'h', "J": 'j', "K": 'k', "L": 'l', "Semicolon": ';', "Apostrophe": "'",
	"Z": 'z', "X": 'x', "C": 'c', "V": 'v', "B": 'b', "N": 'n', "M": 'm', "Comma": ',', "Period": '.', "Slash": '/', "space": "Space"
}

func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("toggle_option_bool", self, "toggle_options")

func _input(event) -> void:
	if Global.in_game and not SceneHandler.transition:
		if event is InputEventKey:
			if event.pressed:
				#if chat focused
				if line_edit.get_focus_owner() == line_edit:
					#chat focused + enter
					if event.scancode == KEY_ENTER:
						# send chat
						if line_edit.text.length() > 0:
							Signals.emit_signal("send_message")
							line_edit.text = ""
						# empty line = unfocus
						else:
							#print("line edit will unfocus")
							line_edit.release_focus()
					# if chat and escape = unfocus
					elif event.scancode == KEY_ESCAPE:
							line_edit.release_focus()
					# if chat + tab = cycle chat
					elif event.scancode == KEY_TAB:
							Signals.emit_signal("toggle_chat_group")
				# not focus chat
				else:
					if options_toggled:
						if event.scancode == KEY_ESCAPE:
							toggle_options()
							Signals.emit_signal("toggle_options")
					else:
						# chat not focus + esc -> options
						if event.is_action_pressed("ui_cancel"):
							options_toggled = not options_toggled
							AudioControl.play_audio("windowToggle")
							Signals.emit_signal("toggle_options")
						# chat not focus + enter = focus chat
						elif event.scancode == KEY_ENTER:
							line_edit.grab_focus()
####################################################################################################
						else:
							parse_keybind(event)
	else:
		pass
#		if event is InputEventKey:
#			parse_keybind(event)
#			#print(event.scancode)
#		else:
#			pass

func toggle_options() -> void:
	options_toggled = not options_toggled

func parse_keybind(input: InputEventKey) -> void:
	#print(input.as_text())
	if keybind_dict.has(input.as_text()):
		#print("parse keybind %s in keybind_dict" % input.as_text())
		var keybind = Global.player.keybind[keybind_dict[input.as_text()]]
		if keybind == "stat":
			AudioControl.play_audio("windowToggle")
			Signals.emit_signal("toggle_stats")
		elif keybind == "inventory":
			#print("inventory")
			Signals.emit_signal("toggle_inventory")
			AudioControl.play_audio("windowToggle")
		elif keybind == "skill":
			Signals.emit_signal("toggle_skills")
			AudioControl.play_audio("windowToggle")
		elif keybind == "equipment":
			Signals.emit_signal("toggle_equipment")
			AudioControl.play_audio("windowToggle")
		else:
			# skill
			if GameData.skill_class_dictionary.has(str(keybind)):
				Server.use_skill(str(keybind))
				#Global.player_node.input = keybind
			# item
			elif GameData.itemTable.has(keybind):
				Server.use_item(str(keybind), find_item(str(keybind)))
			else:
				#print("inputmanager.gd -> parse_keybind else: %s input" % input.as_text())
				var key = Global.player.keybind[keybind_dict[input.as_text()]]
				if key == "attack":
					Signals.emit_signal("attack")
	else:
		if input.as_text() == "BackSlash":
			Signals.emit_signal("toggle_keybinds")
		
func find_item(id: String) -> int:
	var inv_ref = Global.player.inventory.use
	var count = 0
	for item in inv_ref:
		if item.id == id:
			break
		else:
			count += 1
	return count
