extends Node

var player_spawn = preload("res://scenes/playerObjects/PlayerTemplate.tscn")
var playerScene = preload("res://scenes/playerObjects/Player.tscn")

var playerSpawnPosition = Vector2.ZERO
var currentPlayerNode = null

var monsterScene = preload("res://scenes/Monster.tscn")

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
###################################################################
	
func register_player(player):
		currentPlayerNode = player
		currentPlayerNode.connect("died", self, "on_player_died", [], CONNECT_DEFERRED)


func create_player():
	var playerInstance = playerScene.instance()
	add_child_below_node(currentPlayerNode, playerInstance)
	playerInstance.global_position = playerSpawnPosition
	print(playerSpawnPosition)
	register_player(playerInstance)


func on_player_died():
	print("Player Died")
	currentPlayerNode.queue_free()
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

