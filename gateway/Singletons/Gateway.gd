extends Node

var network = ENetMultiplayerPeer.new()
var gateway_api : MultiplayerAPI
var port = 2734
var max_players = 100
var cert = load("res://Resources/Certificate/X509_Certificate.crt")
var key = load("res://Resources/Certificate/x509_Key.key")

func _ready():
	start_server()
	
func _process(_delta):
	if not gateway_api.has_multiplayer_peer():
		return
	gateway_api.poll()
	
func start_server():
	"""
	network.set_dtls_enabled(true)
	network.set_dtls_key(key)
	network.set_dtls_certificate(cert)
	"""
	network.create_server(port, max_players)
	gateway_api =  MultiplayerAPI.create_default_interface()
	get_tree().set_multiplayer(gateway_api, self.get_path())
	gateway_api.multiplayer_peer = network
	gateway_api.peer_connected.connect(_Peer_Connected)
	gateway_api.peer_disconnected.connect(_Peer_Disconnected)
	print("Gateway server started")
	
func _Peer_Connected(player_id):
	print("Gateway Server _on_peer_connected, peer_id: {0}".format([player_id]))

func _Peer_Disconnected(player_id):
	print("Gateway Server _on_peer_disconnected, peer_id: {0}".format([player_id]))
	
@rpc("any_peer")
func login_request(username, password):
	print("login request recieved")
	var player_id = multiplayer.get_remote_sender_id()
	Authenticate.authenticate_player(username, password, player_id)

@rpc("any_peer")
func return_login_request(result, player_id):
	print("return login request to client")
	#print(result)
	rpc_id(player_id, "return_login", result)

@rpc("any_peer")
func return_login(_result):
	pass

@rpc("any_peer")
func client_disconnect():
	print("disconnecting client")
	var player_id = multiplayer.get_remote_sender_id()
	network.disconnect_peer(player_id)
