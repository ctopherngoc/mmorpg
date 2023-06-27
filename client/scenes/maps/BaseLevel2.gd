extends Node


var playerScene = preload("res://scenes/playerObjects/Player.tscn")
var playerSpawnPosition = Vector2.ZERO
var currentPlayerNode = null

var monsterScene = preload("res://scenes/Monster.tscn")
var monster1SpawnPosition = Vector2.ZERO
var monster1Node = null

var monster2SpawnPosition = Vector2.ZERO
var monster2Node = null

#teleporter end locations
onready var teleporter1 : Label = $MapObjects/Teleporter1/Label
onready var teleporter2 : Label = $MapObjects/Teleporter2/Label
onready var teleporter = [Vector2(-135, -225.500488), Vector2(657.772644, -225.575974)]

func _ready():
	self.name = "currentScene"
	Global.change_background()
	if Global.player.lastmap != get_filename():
		Global.update_lastmap(get_filename())
		playerSpawnPosition = $Player.global_position
	
	if Global.last_portal:
		$Player.global_position = Global.last_portal
	print($Player.global_position)
	print($MapObjects/Portal1.global_position)
	
func register_player(player):
		currentPlayerNode = player
		#print(currentPlayerNode.global_position)
		currentPlayerNode.connect("died", self, "on_player_died", [], CONNECT_DEFERRED)
		
func register_monster(monster):
		var monsterNode = monster
		#print(currentMonsterNode.global_position)
		monsterNode.connect("monster_died", self, "on_monster_died", [monsterNode, monsterNode.global_position], CONNECT_DEFERRED)

func create_player():
	var playerInstance = playerScene.instance()
	add_child_below_node(currentPlayerNode, playerInstance)
	playerInstance.global_position = playerSpawnPosition
	print(playerSpawnPosition)
	register_player(playerInstance)
	
func create_monster(monsterNode, monsterSpawnPosition):
	var monsterInstance = monsterScene.instance()
	add_child_below_node(monsterNode, monsterInstance)
	monsterInstance.global_position = monsterSpawnPosition
	register_monster(monsterInstance)
	
func on_player_died():
	print("Player Died")
	currentPlayerNode.queue_free()
	print("Play Respawned")
	create_player()
	
func on_monster_died(monsterNode, monsterSpawnPosition):
	print(str(monsterNode) + " Died")
	#get_parent().add_child(Coin)
	monsterNode.queue_free()
	print("Monster Respawned")
	create_monster(monsterNode, monsterSpawnPosition)

#func _on_noCol_body_entered(body):
#	if body.is_in_group("player"):
#		body.set_collision_layer_bit(0, false)
#		body.set_collision_mask_bit(0, false)
#
#
#func _on_noCol_body_exited(body):
#	print("out of area")
#	if body.is_in_group("player"):
#		body.set_collision_layer_bit(0, true)
#		body.set_collision_mask_bit(0, true)

#func _on_teleport_zone_area_entered(area):
#	print("entered")
#	currentPlayerNode.global_position = playerSpawnPosition


func _on_teleport_zone_body_entered(body):
	print("entered")
	body.global_position = Vector2(103, -250)
