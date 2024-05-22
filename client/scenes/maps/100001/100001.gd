extends Node2D
var map_id = "100001"
var map_name = "Grassy Road 1"

var other_player_template = preload("res://scenes/playerObjects/PlayerTemplate.tscn")
var spawn_location = Vector2.ZERO
#var main_player = null

var map_bound = {
	"left": 0,
	"right": 1000,
	"bottom": 30,
	"top": -10000,
}

#var greenGuy = preload("res://scenes/monsterObjects/100001/100001.tscn")
#var monster_list = {
#	'100001': greenGuy,
#}

func _ready():
	#self.name = "Map"
	var gameWorld = self.get_parent().get_parent()
	
	if str(Global.player.map) != get_filename():
		Global.update_lastmap(get_filename())
	spawn_location = Vector2(113,-275)
	gameWorld.player.camera.limit_left = map_bound["left"]
	gameWorld.player.camera.limit_right = map_bound["right"]
	gameWorld.player.camera.limit_bottom = map_bound["bottom"]
	gameWorld.player.camera.limit_top = map_bound["top"]

	if Global.last_portal:
		gameWorld.player.global_position = Global.last_portal
	else:
		gameWorld.player.global_position = spawn_location
