extends Node2D
var map_id = "100002"
var map_name = "Grassy Road 2"

var other_player_template = preload("res://scenes/playerObjects/PlayerTemplate.tscn")
var spawn_location = Vector2.ZERO

var map_bound = {
	"left": 0,
	"right": 1000,
	"bottom": 30,
	"top": -10000,
}

#teleporter end locations
onready var teleporter1 : Label = $MapObjects/T1/Label
onready var teleporter2 : Label = $MapObjects/T2/Label
onready var teleporter = [Vector2(-135, -225.500488), Vector2(657.772644, -225.575974)]

func _ready():
	#self.name = "Map"
	var gameWorld = self.get_parent().get_parent()
	
	Global.change_background()
	if Global.player.map != get_filename():
		Global.update_lastmap(get_filename())
		spawn_location = Vector2(234, -437)
	gameWorld.player.camera.limit_left = map_bound["left"]
	gameWorld.player.camera.limit_right = map_bound["right"]
	gameWorld.player.camera.limit_bottom = map_bound["bottom"]
	gameWorld.player.camera.limit_top = map_bound["top"]
	
	if Global.last_portal:
		gameWorld.player.global_position = Global.last_portal
	else:
		gameWorld.player.global_position = spawn_location

###############################################################################################
func _on_teleport_zone_body_entered(body):
	print("entered")
	body.global_position = Vector2(103, -250)

