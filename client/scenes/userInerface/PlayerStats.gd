extends Control

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
