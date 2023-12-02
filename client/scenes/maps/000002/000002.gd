extends Node
var map_id = "000002"
var map_name = "Grassy Road 2"
var other_player_template = preload("res://scenes/playerObjects/PlayerTemplate.tscn")
var main_player_template = preload("res://scenes/playerObjects/Player.tscn")

var spawn_location = Vector2.ZERO
var main_player = null
var greenGuy = preload("res://scenes/monsterObjects/000001/000001.tscn")
var blueGuy = preload("res://scenes/monsterObjects/000002/000002.tscn")

var monster_list = {
	'000001': greenGuy,
	'000002': blueGuy,
}

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
	self.name = "currentScene"
	Global.change_background()
	if Global.player.lastmap != get_filename():
		Global.update_lastmap(get_filename())
		spawn_location = Vector2(234, -437)
	$Player/Camera2D.limit_left = map_bound["left"]
	$Player/Camera2D.limit_right = map_bound["right"]
	$Player/Camera2D.limit_bottom = map_bound["bottom"]
	$Player/Camera2D.limit_top = map_bound["top"]
	
	if Global.last_portal:
		$Player.global_position = Global.last_portal
	#print($Player.global_position)
	#print($MapObjects/Portal1.global_position)
	
func register_player(player):
		main_player = player
		main_player.connect("died", self, "on_player_died", [], CONNECT_DEFERRED)

func create_player():
	var player_instance = main_player_template.instance()
	add_child_below_node(main_player, player_instance)
	player_instance.global_position = spawn_location
	register_player(player_instance)

func on_player_died():
	print("Player Died")
	main_player.queue_free()
	print("Play Respawned")
	create_player()

func _on_noCol_body_entered(body):
	if body.is_in_group("player"):
		body.set_collision_layer_bit(0, false)
		body.set_collision_mask_bit(0, false)


func _on_noCol_body_exited(body):
	print("out of area")
	if body.is_in_group("player"):
		body.set_collision_layer_bit(0, true)
		body.set_collision_mask_bit(0, true)

###############################################################################################
func _on_teleport_zone_body_entered(body):
	print("entered")
	body.global_position = Vector2(103, -250)
