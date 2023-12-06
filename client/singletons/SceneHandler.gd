extends Node

onready var current_scene_container = preload("res://scenes/menuObjects/LoginScreen.tscn")
onready var current_scene = "menu"
onready var current_bgm = "menu"

# menu hash map
onready var menu_scenes = {
	"mainMenu" : "res://scenes/menuObjects/mainMenu.tscn",
	"register" : "res://scenes/menuObjects/RegisterScreen.tscn",
	"login" : "res://scenes/menuObjects/LoginScreen.tscn",
	"characterSelect" : "res://scenes/menuObjects/UserProfile.tscn",
	"create": "res://scenes/menuObjects/Create.tscn",
}

func _ready():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/menuObjects/LoginScreen.tscn")

func _process(_delta):
	# turn on music
	if Global.bgm.playing == false:
		Global.bgm.playing = true

func change_scene(scene: String):
# warning-ignore:return_value_discarded
	# if in menu
	if scene in menu_scenes.keys():
		get_tree().change_scene(menu_scenes[scene])
		if current_bgm != "menu":
			Global.bgm.set_stream(GameData.bgm_dict["menu"])
	else:
		# if in map
		Global.current_map = scene
		print(Global.current_map, " ", GameData.map_dict[scene]["name"])
		
		# if map different bgm
		if GameData.map_dict[scene]["bgm"] != current_bgm:
			current_bgm = GameData.map_dict[scene]["bgm"]
			Global.bgm.set_stream(GameData.bgm_dict[GameData.map_dict[scene]["bgm"]])
# warning-ignore:return_value_discarded
		get_tree().change_scene(GameData.map_dict[scene]["path"])
