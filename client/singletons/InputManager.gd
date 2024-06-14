extends Node

var line_edit: LineEdit
var options_toggled = false
#var keybind_dict = {"KEY_SHIFT": 'shift', "KEY_INSERT": 'ins', "KEY_HOME": 'home',"KEY_PAGEUP": 'pgup',"KEY_CONTROL": 'ctrl', "KEY_DELETE": 'del',"KEY_END": 'end',"KEY_PAGEDOWN": 'pgdn',
#	"KEY_QUOTELEFT ": '`', "KEY_1": '1', "KEY_2": '2', "KEY_3": '3', "KEY_4": '4', "KEY_5": '5', "KEY_6": '6', "KEY_7": '7', "KEY_8": '8', "KEY_9": '9', "KEY_0": '0', "KEY_MINUS": '-', "KEY_EQUAL": '=',
#	 "KEY_F1": 'f1', "KEY_F2": 'f2', "KEY_F3": 'f3', "KEY_F4": 'f4', "KEY_F5": 'f5', "KEY_F6": 'f6', "KEY_F7": 'f7', "KEY_F8": 'f8', "KEY_F9": 'f9', "KEY_F10": 'f10', "KEY_F11": 'f11', "KEY_F12": 'f12',
#	"KEY_Q": 'q', "KEY_W": 'w', "KEY_E": 'e', "KEY_R": 'r', "KEY_T": 't', "KEY_Y": 'y', "KEY_U": 'u', "KEY_I": 'i', "KEY_O": "o", "KEY_P": 'p', "KEY_BRACKETLEFT": '[', "KEY_BRACKETRIGHT": ']',
#	"KEY_A": 'a', "KEY_S": 's', "KEY_D": 'd', "KEY_F": 'f', "KEY_G": 'g', "KEY_H": 'h', "KEY_J": 'j', "KEY_K": 'k', "KEY_L": 'l', "KEY_SEMICOLON": ';', "KEY_APOSTROPHE": "'",
#	"KEY_Z": 'z', "KEY_X": 'x', "KEY_C": 'c', "KEY_V": 'v', "KEY_B": 'b', "KEY_N": 'n', "KEY_M": 'm', "KEY_COMMA": ',', "KEY_PERIOD": '.', "KEY_SLASH": '/',
#
#}

var keybind_dict = {"Shift": 'shift', "Insert": 'ins', "Home": 'home',"PageUp": 'pgup',"Control": 'ctrl', "Delete": 'del',"End": 'end',"PageDown": 'pgdn',
	"QuoteLeft": '`', "1": '1', "2": '2', "3": '3', "4": '4', "5": '5', "7": '7', "8": '8', "9": '9', "0": '0', "Minus": '-', "Equal": '=',
	 "F1": 'f1', "F2": 'f2', "F3": 'f3', "F4": 'f4', "F5": 'f5', "F6": 'f6', "F7": 'f7', "F8": 'f8', "F9": 'f9', "F0": 'f10', "F11": 'f11', "F12": 'f12',
	"Q": 'q', "W": 'w', "E": 'e', "R": 'r', "T": 't', "Y": 'y', "U": 'u', "I": 'i', "O": "o", "P": 'p', "BracketLeft": '[', "BracketRight": ']',
	"A": 'a', "S": 's', "D": 'd', "F": 'f', "G": 'g', "H": 'h', "J": 'j', "K": 'k', "L": 'l', "Semicolon": ';', "Apostrophe": "'",
	"Z": 'z', "X": 'x', "C": 'c', "V": 'v', "B": 'b', "N": 'n', "M": 'm', "Comma": ',', "Period": '.', "Slash": '/',
}

func _ready():
# warning-ignore:return_value_discarded
	Signals.connect("toggle_option_bool", self, "toggle_options")

func _input(event) -> void:
	if Global.in_game:
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
							print("line edit will unfocus")
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
							if event.is_action_pressed("stats"):
								AudioControl.play_audio("windowToggle")
								Signals.emit_signal("toggle_stats")
								print("toggle stats")
							elif event.is_action_pressed("inventory"):
								Signals.emit_signal("toggle_inventory")
								AudioControl.play_audio("windowToggle")
								print("toggle inventory")
							elif event.scancode == KEY_K:
								Signals.emit_signal("toggle_skills")
								AudioControl.play_audio("windowToggle")
	else:
		if event is InputEventKey:
			parse_keybind(event)
			#print(event.scancode)
		else:
			pass

func toggle_options() -> void:
	options_toggled = not options_toggled

func parse_keybind(input) -> void:
	print(input.as_text())
	if not input.as_text() in ["Up", "Left", "Down", "Right", "Alt"]:
		var keybind = Global.default_keybind[input.as_text()]
		if keybind == "stat":
			AudioControl.play_audio("windowToggle")
			Signals.emit_signal("toggle_stats")
		elif keybind == "inventory":
			Signals.emit_signal("toggle_inventory")
			AudioControl.play_audio("windowToggle")
		elif keybind == "skill":
			Signals.emit_signal("toggle_skills")
			AudioControl.play_audio("windowToggle")
	else:
		print("movement: %s" % input.as_text())
	#print(Global.player.keybind[input.as_text()])
	#print(keybind_dict[str(input.scancode)])
