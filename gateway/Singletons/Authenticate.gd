extends Node

var network = ENetMultiplayerPeer.new()
var auth_api : MultiplayerAPI
var port = 2735
#var ip = "172.17.0.2"
var ip = "127.0.0.1"

func _ready():
	connect_to_server()
	
func connect_to_server():
	network.create_client(ip, port)
	auth_api = MultiplayerAPI.create_default_interface()
	get_tree().set_multiplayer(auth_api, self.get_path())
	auth_api.multiplayer_peer = network
	auth_api.connected_to_server.connect(_Connection_Succeeded)
	auth_api.connection_failed.connect(_Connection_Failed)
	
	print("Custom ClientUnique ID: {0}".format([auth_api.get_unique_id()]))
	
func _Connection_Failed():
	print("Failed to conect to authentication server")

func _Connection_Succeeded():
	print("Successfully connected to authentication server")
	print("Auth Peers: {0}".format([multiplayer.get_peers()]))
	
func authenticate_player(username, password, player_id):
	print("sending out authentication request")
	rpc_id(1, "auth_player", username, password, player_id)

@rpc("any_peer")
func auth_player(_username, _password, _player_id):
	pass

@rpc("any_peer")
func authentication_results(result, player_id):
	print("resuts received and replying to player login request")
	Gateway.return_login_request(result, player_id)
