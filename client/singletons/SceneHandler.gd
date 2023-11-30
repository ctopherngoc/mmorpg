extends Node

onready var current_scene_container = preload("res://scenes/userInerface/LoginScreen.tscn")
onready var current_scene = "menu"
onready var current_bgm = "menu"

onready var menu_scenes = {
	"mainMenu" : "res://scenes/userInerface/mainMenu.tscn",
	"register" : "res://scenes/userInerface/RegisterScreen.tscn",
	"login" : "res://scenes/userInerface/LoginScreen.tscn",
	"characterSelect" : "res://scenes/userInerface/UserProfile.tscn",	
}

func _ready():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/userInerface/LoginScreen.tscn")

func _process(_delta):
	if Global.bgm.playing == false:
		Global.bgm.playing = true


func change_scene(scene: String):
# warning-ignore:return_value_discarded
	if scene in menu_scenes.keys():
		get_tree().change_scene(menu_scenes[scene])
		if current_bgm != "menu":
			Global.bgm.set_stream(GameData.bgm_dict["menu"])
	else:
		"""
		GameData.map_dict{mapid: {mapname:fdf, path: res...},}
		scene string should be map_id: EX: 000001
		1. update global current map to map_id
		2. get name path
		3. update global map_name?
		4.  change scene
		"""
		Global.current_map = scene
		# map_id
		print(Global.current_map, GameData.map_dict[scene]["name"])
		
		"""
		channge. Possibly add  region to map hash and edit bgm keys to be based off of region
		"""
		if GameData.map_dict[scene]["bgm"] != current_bgm:
			current_bgm = GameData.map_dict[scene]["bgm"]
			Global.bgm.set_stream(GameData.bgm_dict[GameData.map_dict[scene]["bgm"]])
# warning-ignore:return_value_discarded
		get_tree().change_scene(GameData.map_dict[scene]["path"])
