extends Node
var map_id = "100002"
var map_name = "Grassy Road 2"

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

var greenGuy = preload("res://scenes/monsterObjects/000001/000001.tscn")
var blueGuy = preload("res://scenes/monsterObjects/000002/000002.tscn")
var monster_list = {
	'000001': greenGuy,
	'000002': blueGuy,
}

#teleporter end locations
onready var teleporter1 : Label = $MapObjects/T1/Label
onready var teleporter2 : Label = $MapObjects/T2/Label
onready var teleporter = [Vector2(-135, -225.500488), Vector2(657.772644, -225.575974)]

func _ready():
	self.name = "currentScene"
	Global.change_background()
	if Global.player.map != get_filename():
		Global.update_lastmap(get_filename())
		spawn_location = Vector2(234, -437)
	$Player/Camera2D.limit_left = map_bound["left"]
	$Player/Camera2D.limit_right = map_bound["right"]
	$Player/Camera2D.limit_bottom = map_bound["bottom"]
	$Player/Camera2D.limit_top = map_bound["top"]
	
	if Global.last_portal:
		$Player.global_position = Global.last_portal

func create_player():
	var player_instance = main_player_template.instance()
	add_child_below_node(main_player, player_instance)
	player_instance.global_position = spawn_location
	main_player = player_instance

###############################################################################################
func _on_teleport_zone_body_entered(body):
	print("entered")
	body.global_position = Vector2(103, -250)
