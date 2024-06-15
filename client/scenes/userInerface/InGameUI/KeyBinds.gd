extends Control

signal move_to_top

func _ready():
	# warning-ignore:return_value_discarded
	Signals.connect("toggle_keybinds", self, "toggle_keybinds")

func toggle_keybinds() -> void:
	self.visible = not self.visible
