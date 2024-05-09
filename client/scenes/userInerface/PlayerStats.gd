extends Control

var drag_position
signal move_to_top

onready var strength = get_node("HBoxContainer/VBoxContainer/Strength/Value")
onready var vitality = get_node("HBoxContainer/VBoxContainer/Vitality/Value")
onready var dexterity = get_node("HBoxContainer/VBoxContainer/Dexterity/Value")
onready var intelligence = get_node("HBoxContainer/VBoxContainer/Intelligence/Value")

"""
add so that server does firebase request for 
"""

func _ready():
	Server.fetch_player_stats()

func load_player_stats(stats):
	strength.set_text(str(stats.Strength))
	vitality.set_text(str(stats.Vitality))
	dexterity.set_text(str(stats.Dexterity))
	intelligence.set_text(str(stats.Intelligence))

func _input(event):
	if event.is_action_pressed("stats"):
		self.visible = not self.visible
		print("toggle stats")


func _on_PlayerStats_gui_input(event):
	if event is InputEventMouseButton:
		# left mouse button
		if event.pressed && event.get_button_index() == 1:
			drag_position = get_global_mouse_position() - rect_global_position
			emit_signal('move_to_top', self)
		else:
			drag_position = null
	if event is InputEventMouseMotion and drag_position:
		rect_global_position = get_global_mouse_position() - drag_position
