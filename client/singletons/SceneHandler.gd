extends Node

@onready var current_scene_container = preload("res://scenes/userInerface/LoginScreen.tscn")
@onready var current_scene = "menu"
@onready var current_bgm = "menu"

@onready var scenes = {
	"mainMenu" : "res://scenes/userInerface/mainMenu.tscn",
	"register" : "res://scenes/userInerface/RegisterScreen.tscn",
	"login" : "res://scenes/userInerface/LoginScreen.tscn",
	"characterSelect" : "res://scenes/userInerface/UserProfile.tscn",	
}

func _ready():
# warning-ignore:return_value_discarded
	get_tree().change_scene_to_file("res://scenes/userInerface/LoginScreen.tscn")

func _process(_delta):
	if Global.bgm.playing == false:
		Global.bgm.playing = true


func change_scene_to_file(scene: String):
# warning-ignore:return_value_discarded
	if "/maps" in scene:
		Global.current_map = scene.replace("res://scenes/maps/", "")
		Global.current_map = Global.current_map.replace(".tscn", "")
		print(Global.current_map)
		for key in GameData.bgm_dict.keys():
			if key in Global.current_map:
				if key == current_bgm:
					pass
				else:
					Global.bgm.set_stream(GameData.bgm_dict[key])
					current_bgm = key
		current_scene = Global.current_map
	get_tree().change_scene_to_file(scene)
