extends Control

onready var sound_node = $PanelContainer/TabContainer/Sound
onready var video_node = $PanelContainer/TabContainer/Video
onready var option_path = "user://gameOption.dat"
onready var login = self.get_parent()
onready var tabContainer = $PanelContainer/TabContainer

func _ready() -> void:
	load_settings()
	if not Global.in_game:
		AudioControl.bgm.play()

func _on_back_pressed() -> void:
	AudioControl.play_audio("menuClick")
	save_settings()
	# if in login->menu
	if not Global.in_game:
		login.return_to_login()
	# if testing -> offline

func load_settings() -> void:
	var save_file = File.new()
	if not save_file.file_exists(option_path):
		sound_node.load_settings = true
		return
	save_file.open(option_path, File.READ)
	var settings_data = JSON.parse(save_file.get_as_text())
	
	if "video" in settings_data.result.keys():
		var video_settings =settings_data.result["video"]
		video_node.load_settings(video_settings)
	if "sound" in settings_data.result.keys():
		var sound_settings = settings_data.result["sound"]
		sound_node.masterValue = float(sound_settings.master)
		sound_node.effectValue = float(sound_settings.effect)
		sound_node.musicValue = float(sound_settings.music)
		sound_node.set_sound_values()
		
	print("Options Loaded")
	save_file.close()

func save_settings() -> void:
	sound_node.save_sound_values()
	var file = File.new()
	file.open(option_path, file.WRITE)
	var data ={ "sound": {
		"master": sound_node.masterValue,
		"music": sound_node.musicValue,
		"effect": sound_node.effectValue,
		},
		"video": {
		"vsync": video_node.VsyncToggle.pressed,
		"resolution": String(get_viewport().get_size().x)+"x"+String(get_viewport().get_size().y),
		"fullscreen": video_node.FullscreenToggle.pressed,
		"fps": Engine.target_fps
		}
	}
	file.store_line(JSON.print(data, "\t"))
	#file.store_var(data)
	file.close()
"""
if Resolutions[r] == CurrentResolution:
			ResolutionOptionButton._select_int(index)
"""

func _on_back_mouse_entered() -> void:
	AudioControl.play_audio("menuHover")

func _on_TabContainer_tab_selected(tab) -> void:
	print("Tab %s" % typeof(tab))
	AudioControl.play_audio("menuClick")
