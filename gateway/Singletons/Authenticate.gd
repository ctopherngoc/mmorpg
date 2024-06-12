extends Node

var network = NetworkedMultiplayerENet.new()
var port = 2735
var ip = "127.0.0.1"

func _ready():
	connect_to_server()
	
func connect_to_server():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
	
func _OnConnectionFailed():
	print("Failed to conect to authentication server")

func _OnConnectionSucceeded():
	print("Successfully connected to authentication server")
	
remote func authenticate_player(username, password, player_id):
	print("sending out authentication request")
	rpc_id(1, "authenticate_player", username, password, player_id)
	
remote func authentication_results(result, player_id):
	print("resuts received and replying to player login request")
	Gateway.return_login_request(result, player_id)
