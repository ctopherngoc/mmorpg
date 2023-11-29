extends Node

# singleton: http.gd links variable to httprequest
@onready var http : HTTPRequest
var network = ENetMultiplayerPeer.new()
var auth_api : MultiplayerAPI
var port = 2735
var max_servers = 5

func _ready():
	start_server()

func start_server():
	network.create_server(port, max_servers)
	auth_api =  MultiplayerAPI.create_default_interface()
	get_tree().set_multiplayer(auth_api, self.get_path())
	auth_api.multiplayer_peer = network
	auth_api.peer_connected.connect(_Peer_Connected)
	auth_api.peer_disconnected.connect(_Peer_Disconnected)
	print("Authentication server started")

func _Peer_Connected(gateway_id):
	print("Auth Server _on_peer_connected, peer_id: {0}".format([gateway_id]))

func _Peer_Disconnected(gateway_id):
	print("Auth Server _on_peer_disconnected, peer_id: {0}".format([gateway_id]))
	
@rpc("any_peer")
func auth_player(username, password, player_id):
	print("authentication request received")
	var gateway_id = multiplayer.get_remote_sender_id()
	
	print("Starting authentication")
	print("this is http: %s" % http)
	var results = []
	await Firebase.login(username, password, results)
	
	if results[0] != 200:
		print("Signin Unsuccessful")
	else:
		print("Signin Successful")
		var server = "GameServer1"
		var temp_token = results[1]['token'] + str(results[1]['timestamp'])
		Server.distribute_login_token(temp_token, server)
		
	print("authentication result send to gateway server")
	rpc_id(gateway_id, "authentication_results", results, player_id)
	
@rpc("any_peer")
func authentication_results(_result, _player_id):
	pass
