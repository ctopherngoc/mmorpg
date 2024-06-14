extends Control


func _ready():
	# warning-ignore:return_value_discarded
	Signals.connect("update_keybinds", self, "update_keybinds")

func update_keybinds() -> void:
	print("update keybinds")
