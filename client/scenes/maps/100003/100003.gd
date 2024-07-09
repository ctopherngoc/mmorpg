extends Node2D
var map_id = "100003"
var map_name = "Grassy Road 3"
onready var monsters = $Monsters
var spawn_location = Vector2(350, -550)

var map_bound = {
	"left": -296,
	"right": 1678,
	"bottom": 30,
	"top": -10000,
}

#teleporter end locations
#onready var teleporter1 : Label = $MapObjects/T1/Label
#onready var teleporter2 : Label = $MapObjects/T2/Label
onready var teleporter = [Vector2(-135, -225.500488), Vector2(657.772644, -225.575974)]

func _ready():
# warning-ignore:unused_variable
	var gameWorld = self.get_parent().get_parent()

	Global.change_background()
	if Global.player.map != get_filename():
		Global.update_lastmap(get_filename())
	
	$Player.camera.limit_left = map_bound["left"]
	$Player.camera.limit_right = map_bound["right"]
	$Player.camera.limit_bottom = map_bound["bottom"]
	$Player.camera.limit_top = map_bound["top"]
	
	if Global.last_portal:
		print("spawning here")
		print("server position: %s" % Global.last_portal)
		$Player.global_position = Global.last_portal
		print("player position: %s" % $Player.global_position)
	else:
		$Player.global_position = spawn_location

###############################################################################################
func _on_teleport_zone_body_entered(body):
	print("entered")
	#body.global_position = Vector2(103, -250)
