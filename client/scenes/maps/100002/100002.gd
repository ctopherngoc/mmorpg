extends Node2D
var map_id = "100002"
var map_name = "Grassy Road 2"
onready var monsters = $Monsters

var spawn_location = Vector2(237, -683)

var map_bound = {
	"left": 0,
	"right": 1678,
	"bottom": 30,
	"top": -10000,
}

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
		$Player.position = Global.last_portal
		print("player position: %s" % $Player.position)
	else:
		$Player.position = spawn_location
		print("spawning at diff spot")
		print($Player.position)

###############################################################################################
func _on_teleport_zone_body_entered(body):
	print("entered")
	#body.global_position = Vector2(103, -250)
