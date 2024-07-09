extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 2736

onready var server = get_node("/root/Server")

func _process(_delta: float) -> void:
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return;
	custom_multiplayer.poll()
	
func connect_to_server() -> void:
	print("attempting to connect to game server hub")
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)

	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")

func _OnConnectionFailed() -> void:
	print("Failed to connect to Game Server Hub")

func _OnConnectionSucceeded() -> void:
	print("Successfully connected to Game Server Hub")

remote func received_login_token(token):
	server.expected_tokens.append(token)
