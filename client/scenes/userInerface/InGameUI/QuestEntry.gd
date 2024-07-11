extends Label

onready var quest_id
onready var quest_data

func _ready():
	pass

func _on_QuestEntry_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			print("open quest detail page")
			AudioControl.play_audio("menuClick")
			Signals.emit_signal("toggle_quest_details", quest_data)
