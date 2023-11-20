extends Node

onready var current_scene_container = preload("res://scenes/userInerface/LoginScreen.tscn")
onready var current_scene = "menu"
onready var current_bgm = "login"

onready var scenes = {
	"mainMenu" : "res://scenes/userInerface/mainMenu.tscn",
	"register" : "res://scenes/userInerface/RegisterScreen.tscn",
	"login" : "res://scenes/userInerface/LoginScreen.tscn",
	"characterSelect" : "res://scenes/userInerface/UserProfile.tscn",	
}

func _ready():
# warning-ignore:return_value_discarded
	#print(get_tree())
	get_tree().change_scene("res://scenes/userInerface/LoginScreen.tscn")
	print(Global.bgm.stream)
	#$bgm.play()

func _process(_delta):
	if Global.bgm.playing == false:
		Global.bgm.playing = true


func change_scene(scene: String):
# warning-ignore:return_value_discarded
	#print(scene)
	if "/maps" in scene:
		if current_bgm == "login":
			Global.bgm.set_stream(Global.bgm_dict["baselevel"])
		Global.current_map = scene.replace("res://scenes/maps/", "")
		Global.current_map = Global.current_map.replace(".tscn", "")
		print(Global.current_map)
		current_scene = Global.current_map
		#Global.world_state_buffer.clear()
	get_tree().change_scene(scene)
