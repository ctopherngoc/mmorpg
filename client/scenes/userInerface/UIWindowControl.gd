extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var non_movable_windows = ["InGameMenu", "PlayerHUD"]

# Called when the node enters the scene tree for the first time.
func _ready():
	for window in get_children():
		if not window.name in non_movable_windows:
			print(window.name)
			window.connect('move_to_top', self, 'move_window_to_top')

func move_window_to_top(node):
	move_child(node, get_child_count() - 3)
