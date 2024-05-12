extends CanvasLayer

#onready var current_scene_container = preload("res://scenes/menuObjects/LoginScreen/LoginScreen.tscn")
#onready var current_scene = "menu"
onready var current_bgm = "menu"
onready var option_path = "user://gameOption.dat"

# menu hash map
onready var menu_scenes = {
	"logoScreen": null,
	"mainMenu" : "res://scenes/menuObjects/mainMenu.tscn",
	"register" : "res://scenes/menuObjects/RegisterScreen/RegisterScreen.tscn",
	"login" : "res://scenes/menuObjects/LoginScreen/LoginScreen.tscn",
	"characterSelect" : "res://scenes/menuObjects/CharacterSelect/UserProfile.tscn",
	"create": "res://scenes/menuObjects/CharacterCreate/Create.tscn",
}

onready var Resolutions: Dictionary = {"3840x2160":Vector2(3840,2160),
								"2560x1440":Vector2(2560,1440),
								"2560x1080":Vector2(2560,1080),
								"1920x1080":Vector2(1920,1080),
								"1366x768":Vector2(1366,768),
								"1280x720":Vector2(1280,720),
								"1536x864":Vector2(1536,864),
								"1440x900":Vector2(1440,900),
								"1600x900":Vector2(1600,900),
								"1024x576":Vector2(1024,576),
								"800x600": Vector2(800,600)}

onready var video_settings: Dictionary

func _ready() -> void:
	load_window_settings()

func _process(_delta):
	pass

func load_window_settings():
	var save_file = File.new()
	if not save_file.file_exists(option_path):
		var file = File.new()
		file.open(option_path, file.WRITE)
		var data ={
			"sound": {
				"master": 1.0,
				"music": 1.0,
				"effect": 1.0,},
			"video": {
				"vsync": false,
				"resolution": "1280x720",
				"fullscreen": false,}
			}
		file.store_line(JSON.print(data, "\t"))
		file.close()
	save_file.open(option_path, File.READ)
	var settings_data = JSON.parse(save_file.get_as_text())
	video_settings = settings_data.result["video"]
	load_video_settings(SceneHandler.video_settings)
	save_file.close()

func load_video_settings(settings: Dictionary) -> void:
	if settings.vsync:
		OS.set_use_vsync(true)
	if settings.fullscreen:
		OS.set_window_fullscreen(true)
	else:
		OS.set_window_size(Resolutions[settings.resolution])
		OS.center_window()


func change_scene(scene: String) -> void:
# warning-ignore:return_value_discarded
	# if in menu
	# makes screen black
	if Global.in_game:
			get_node("/root/currentScene").visible = false
	$AnimationPlayer.play("dissolve")
	yield($AnimationPlayer, "animation_finished")
	if scene in menu_scenes.keys():
		get_tree().change_scene(menu_scenes[scene])
		if current_bgm != "menu":
			AudioControl.bgm.set_stream(GameData.bgm_dict["menu"])
			current_bgm = "menu"
	else:
		# if in map
		Global.current_map = scene
		print(Global.current_map, " ", GameData.map_dict[scene]["name"])
		
		# if map different bgm
		if GameData.map_dict[scene]["bgm"] != current_bgm:
			print("%s != %s" % [GameData.map_dict[scene]["bgm"], current_bgm])
			current_bgm = GameData.map_dict[scene]["bgm"]
			AudioControl.bgm.set_stream(GameData.bgm_dict[GameData.map_dict[scene]["bgm"]])
			AudioControl.bgm.play()
		# warning-ignore:return_value_discarded
		get_tree().change_scene(GameData.map_dict[scene]["path"])
		if Global.in_game:
			get_node("/root/currentScene").visible = true
	$AnimationPlayer.play_backwards("dissolve")
	
#func _unhandled_input(event):
#	if event.pressed and event.scancode == KEY_SPACE:
#		get_node("/root/currentScene").visible = false
#		$AnimationPlayer.play("dissolve")
#		yield($AnimationPlayer, "animation_finished")
#		get_node("/root/currentScene").visible = true
#		$AnimationPlayer.play_backwards("dissolve")
