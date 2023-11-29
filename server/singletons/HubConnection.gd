extends Node

var network = ENetMultiplayerPeer.new()
var hub_api = null
var ip = "127.0.0.1"
var port = 2736

@onready var server = get_node("/root/Server")

func _ready():
	connect_to_server()

func _process(_delta):
	if hub_api == null:
		return
	if not hub_api.has_multiplayer_peer():
		return
	hub_api.poll()
	
func connect_to_server():
	print("attempting to connect to game server hub")
	network.create_client(ip, port)
	hub_api = MultiplayerAPI.create_default_interface()
	get_tree().set_multiplayer(hub_api, self.get_path())
	hub_api.multiplayer_peer = network
	hub_api.connected_to_server.connect(_Connection_Succeeded)
	hub_api.connection_failed.connect(_Connection_Failed)

func _Connection_Failed():
	print("Failed to connect to Game Server Hub")

func _Connection_Succeeded():
	print("Successfully connected to Game Server Hub")

@rpc("any_peer")
func received_login_token(token):
	server.expected_tokens.append(token)
