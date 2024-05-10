extends Control

onready var sound_node = $PanelContainer/TabContainer/Sound
onready var video_node = $PanelContainer/TabContainer/Video
onready var option_path = "user://gameOption.dat"
func _on_back_pressed():
	var file = File.new()
	file.open(option_path, file.WRITE)
	var data = {}
	file.store_var(data)
	file.close()
"""
if Resolutions[r] == CurrentResolution:
			ResolutionOptionButton._select_int(index)
"""
