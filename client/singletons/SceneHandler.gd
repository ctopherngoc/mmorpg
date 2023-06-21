extends Node

onready var current_scene_container = preload("res://scenes/userInerface/mainMenu.tscn")
onready var currentScene

onready var scenes = {
	"mainMenu" : "res://scenes/userInerface/mainMenu.tscn",
	"register" : "res://scenes/userInerface/RegisterScreen.tscn",
	"login" : "res://scenes/userInerface/LoginScreen.tscn",
	"characterSelect" : "res://scenes/userInerface/UserProfile.tscn",	
}

func _ready():
# warning-ignore:return_value_discarded
	#print(get_tree())
	get_tree().change_scene("res://scenes/userInerface/mainMenu.tscn")

func changeScene(scene: String):
# warning-ignore:return_value_discarded
	#print(scene)
	if "/maps" in scene:
		#print("inside")
		Global.current_map = scene.replace("res://scenes/maps/", "")
		Global.current_map = Global.current_map.replace(".tscn", "")
		print(Global.current_map)
		# insert call to send map change
	get_tree().change_scene(scene)

# currently used by server.gd to display server dc message on main menu
#func changeMenuMessage(message: String):
#	var menuLabel = get_node("/root/mainMenu/Label")
#	print("we made it")
#	print(str(menuLabel))
#	#print(currentScene)
#	menuLabel.text = message
