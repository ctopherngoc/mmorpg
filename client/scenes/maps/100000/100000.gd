extends Node
var map_id = "100001"
var map_name = "Grassy Road 1"

var other_player_template = preload("res://scenes/playerObjects/PlayerTemplate.tscn")
var main_player_template = preload("res://scenes/playerObjects/Player.tscn")
var spawn_location = Vector2.ZERO
var main_player = null



var map_bound = {
	"left": 0,
	"right": 1000,
	"bottom": 30,
	"top": -10000,
}

var greenGuy = preload("res://scenes/monsterObjects/100001/100001.tscn")
var monster_list = {
	'100001': greenGuy,
}

func _ready():
	self.name = "currentScene"
	if Global.player.map != get_filename():
		Global.update_lastmap(get_filename())
	spawn_location = Vector2(248,-2000)
	$Player/Camera2D.limit_left = map_bound["left"]
	$Player/Camera2D.limit_right = map_bound["right"]
	$Player/Camera2D.limit_bottom = map_bound["bottom"]
	$Player/Camera2D.limit_top = map_bound["top"]

	if Global.last_portal:
		$Player.global_position = Global.last_portal
	#print("Player: ", $Player.global_position, " Portal1: ", $MapObjects/P1.global_position)

# important for client side spawning and despawning
##################
"""
func register_player(player):
		main_player = player
		main_player.connect("died", self, "on_player_died", [], CONNECT_DEFERRED)
"""

func create_player():
	var player_instance = main_player_template.instance()
	add_child_below_node(main_player, player_instance)
	player_instance.global_position = spawn_location
	main_player = player_instance

############################################
