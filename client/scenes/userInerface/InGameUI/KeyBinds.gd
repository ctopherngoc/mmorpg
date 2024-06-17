extends Control

var drag_position = null
signal move_to_top

func _ready():
	# warning-ignore:return_value_discarded
	Signals.connect("toggle_keybinds", self, "toggle_keybinds")

func toggle_keybinds() -> void:
	self.visible = not self.visible

func _on_KeyBinds_gui_input(event):
	if event is InputEventMouseButton:
		# left mouse button
		if event.pressed && event.get_button_index() == 1:
			print("left mouse button")
			drag_position = get_global_mouse_position() - rect_global_position
			emit_signal('move_to_top', self)
		else:
			drag_position = null
	if event is InputEventMouseMotion and drag_position:
		rect_global_position = get_global_mouse_position() - drag_position
