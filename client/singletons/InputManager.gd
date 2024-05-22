extends Node

var line_edit: LineEdit
var options_toggled = false

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
						elif event.is_action_pressed("stats"):
							AudioControl.play_audio("windowToggle")
							Signals.emit_signal("toggle_stats")
							print("toggle stats")
						elif event.is_action_pressed("inventory"):
							Signals.emit_signal("toggle_inventory")
							AudioControl.play_audio("windowToggle")
							print("toggle inventory")

func toggle_options() -> void:
	options_toggled = not options_toggled

#func _input(event) -> void:
#	if Global.in_game:
#		if event is InputEventKey:
#			if event.pressed and event.scancode == KEY_ENTER:
#				if line_edit.get_focus_owner() == line_edit:
#					if line_edit.text.length() > 0:
#						print("send server entered text")
#						send_message(line_edit.text, group_index)
#						line_edit.text = ""
#					else:
#						print("line edit will unfocus")
#						line_edit.release_focus()
#				else:
#					print("lineedit will be focused")
#					line_edit.grab_focus()
#			elif event.pressed and event.scancode == KEY_ESCAPE:
#				if line_edit.get_focus_owner() == line_edit:
#					print("escape pressed lineedit unfocused")
#					line_edit.release_focus()
#				else:
#					print("escape pressed but chat not focused")
#			elif event.pressed and event.scancode == KEY_TAB and line_edit.get_focus_owner() == line_edit:
#				change_group(1)
