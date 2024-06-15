extends Node2D
var map_id = "100001"
var map_name = "Grassy Road 1"

var spawn_location = Vector2.ZERO

var map_bound = {
	"left": 0,
	"right": 1000,
	"bottom": 30,
	"top": -10000,
}

func _ready():
	var gameWorld = self.get_parent().get_parent()
	
	if str(Global.player.map) != get_filename():
		Global.update_lastmap(get_filename())

	$Player.camera.limit_left = map_bound["left"]
	$Player.camera.limit_right = map_bound["right"]
	$Player.camera.limit_bottom = map_bound["bottom"]
	$Player.camera.limit_top = map_bound["top"]
	
	if Global.last_portal:
		$Player.global_position = Global.last_portal
	else:
		$Player.global_position = spawn_location
