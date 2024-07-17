extends Label

onready var quest_id

func _ready():
	pass

func _on_Label_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			#print("advance to quest dialog")
			AudioControl.play_audio("menuClick")
			Signals.emit_signal("load_quest_dialog", quest_id)
	
func _on_Label_mouse_entered():
	print("mouse entered")
