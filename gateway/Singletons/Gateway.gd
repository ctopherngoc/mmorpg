extends Node

var network = ENetMultiplayerPeer.new()
var gateway_api = MultiplayerAPI.new()
var port = 2734
var max_players = 100
var cert = load("res://Resources/Certificate/X509_Certificate.crt")
var key = load("res://Resources/Certificate/x509_Key.key")

func _ready():
	start_server()
	
func _process(_delta):
	if not custom_multiplayer.has_multiplayer_peer():
		return
	custom_multiplayer.poll()
	
func start_server():
	network.set_dtls_enabled(true)
	network.set_dtls_key(key)
	network.set_dtls_certificate(cert)
	network.create_server(port, max_players)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_multiplayer_peer(network)
	print("Gateway server started")
	
	network.connect("peer_connected", Callable(self, "_Peer_Connected"))
	network.connect("peer_disconnected", Callable(self, "_Peer_Disconnected"))
	
func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")

func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")
	
@rpc("any_peer") func login_request(username, password):
	print("login request recieved")
	var player_id = custom_multiplayer.get_remote_sender_id()
	Authenticate.authenticate_player(username, password, player_id)

func return_login_request(result, player_id):
	print("gateway returnloginrequest back to main login")
	rpc_id(player_id, "return_login_request", result)
	network.disconnect_peer(player_id)
