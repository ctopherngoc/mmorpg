extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1960
var max_players = 100

var server_list = {}

func _ready():
	start_server()

# warning-ignore:unused_argument
func _process(_delta):
	if not custom_multiplayer.has_network_peer():
		return;
	custom_multiplayer.poll()
	
func start_server():
	network.create_server(port, max_players)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("GameServerHub started")

	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _Peer_Connected(server_id):
	print("server " + str(server_id) + " Connected")
	server_list["GameServer1"] = server_id
	
func _Peer_Disconnected(gameserver_id):
	print("server " + str(gameserver_id) + " Disconnected")
	
func distribute_login_token(token, server):
	var server_peer_id = server_list[server]
	print("sent token to server")
	rpc_id(server_peer_id, "received_login_token", token)
	
	
